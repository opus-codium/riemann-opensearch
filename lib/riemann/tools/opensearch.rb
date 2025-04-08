# frozen_string_literal: true

require "riemann/tools"
require "opensearch-ruby"

module Riemann
  module Tools
    class OpenSearch
      class JsonMapper
        def initialize(values)
          values.each do |k, v|
            components = k.split(".")
            last_component = components.pop

            s = self
            components.each do |c|
              s = s.send(c)
            end
            s.send(:"#{last_component}=", normalize(v))
          end
        end

        def normalize(value)
          case value
          when "true" then true
          when "false" then false
          when /\A\d+\z/ then value.to_i
          when /\A\d+\.\d+\z/ then value.to_f
          when /\A\d+\.\d+%\z/ then value.to_f * 0.01
          when "-" then nil
          else value
          end
        end
      end

      class Allocation < JsonMapper
        class Disk
          attr_accessor :indices, :used, :avail, :total, :percent
        end

        attr_accessor :shards, :disk, :host, :ip, :node

        def initialize(values)
          # @disk = Disk.new
          @disk = Struct.new(:indices, :used, :avail, :total, :percent).new
          super
        end
      end

      class Health < JsonMapper
        class Node
          attr_accessor :total, :data
        end

        attr_accessor :epoch, :timestamp, :cluster, :status, :node, :discovered_cluster_manager, :shards, :pri, :relo, :init, :unassign, :pending_tasks, :max_task_wait_time, :active_shards_percent

        def initialize(values)
          @node = Node.new
          super
        end
      end

      include Riemann::Tools

      opt :os_host, "OpenSearch cluster to connect to", short: :none, default: "https://admin:admin@localhost:9200"
      opt :os_ca_cert, "Path to CA certificate file", short: :none, type: :string
      opt :os_cert, "Path to certificate file", short: :none, type: :string
      opt :os_key, "Path to key file", short: :none, type: :string
      opt :os_insecure, "Do not check remote host certificate", short: "-k", default: false

      opt :os_shard_allocation_warning, "Shard allocation warning threshold", short: :none, default: 0.90
      opt :os_shard_allocation_error, "Shard allocation error threshold", short: :none, default: 0.95

      opt :os_disk_usage_warning, "Disk usage warning threshold", short: :none, default: 0.90
      opt :os_disk_usage_error, "Disk usage error threshold", short: :none, default: 0.95

      HEALTH_STATUS_STATE = {
        "green" => :ok,
        "yellow" => :warning,
        "red" => :critical
      }

      def tick
        invalidate_cache

        @client = ::OpenSearch::Client.new(
          host: opts[:os_host],
          transport_options: {
            ssl: {
              ca_file: opts[:os_ca_cert],
              client_cert: opts[:os_cert],
              client_key: opts[:os_key],
              verify: !opts[:os_insecure]
            }
          }
        )

        report({
          service: "#{health.cluster} cluster health",
          state: HEALTH_STATUS_STATE[health.status],
          description: health.status
        })

        max_shards_per_node = setting("cluster.max_shards_per_node")
        allocations.each do |allocation|
          report({
            service: "#{health.cluster} #{allocation.node} shard allocation",
            state: shard_allocation_state(allocation.shards, max_shards_per_node),
            metric: allocation.shards,
            description: "#{allocation.shards}/#{max_shards_per_node}"
          })

          usage = allocation.disk.used.to_f / allocation.disk.total
          report({
            service: "#{health.cluster} #{allocation.node} disk usage",
            state: disk_usage_state(usage),
            metric: usage,
            description: format("%.3f %%", usage * 100)
          })
        end
      end

      def allocations
        @allocations ||= @client.cat.allocation(format: "json", bytes: "b").map do |allocation|
          Allocation.new(allocation)
        end
      end

      def health
        @health ||= @client.cat.health(format: "json").map do |health|
          Health.new(health)
        end.first
      end

      def settings
        @settings ||= @client.cluster.get_settings(include_defaults: true)
      end

      def setting(name)
        pieces = name.split(".")

        value = settings.dig(*(["persistent"] + pieces)) ||
          settings.dig(*(["transient"] + pieces)) ||
          settings.dig(*(["defaults"] + pieces))

        Integer(value)
      rescue ArgumentError
        value
      end

      def disk_usage_state(usage)
        if usage >= opts[:os_disk_usage_error]
          :critical
        elsif usage >= opts[:os_disk_usage_warning]
          :warning
        else
          :ok
        end
      end

      def shard_allocation_state(count, limit)
        if count >= opts[:os_shard_allocation_error] * limit
          :critical
        elsif count >= opts[:os_shard_allocation_warning] * limit
          :warning
        else
          :ok
        end
      end

      private

      def invalidate_cache
        @allocations = nil
        @health = nil
        @settings = nil
      end
    end
  end
end
