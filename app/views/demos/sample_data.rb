# frozen_string_literal: true

module Views
  module Demos
    # Shared sample data for all theme demos
    # Include this module to avoid duplicating demo content across themes
    #
    # Uses Data.define for type-safe data structures matching the pattern
    # established in TabbedNav::Tab and MenuBar::Item
    module SampleData
      # Data structures for type safety
      Stat = Data.define(:value, :label, :highlight) do
        def initialize(value:, label:, highlight: false) = super
      end

      Alert = Data.define(:name, :count, :status, :time) do
        def initialize(name:, count:, status:, time:) = super
        def active? = status == :active
        def paused? = status == :paused
      end

      Patent = Data.define(:id, :title, :assignee, :date, :match, :cpc)

      LogEntry = Data.define(:time, :type, :message)

      TextPart = Data.define(:text, :highlight) do
        def initialize(text:, highlight: false) = super
      end

      ActivityItem = Data.define(:time, :parts, :tag)

      # Status bar info - used by layouts for footer/status displays
      StatusInfo = Data.define(:connected, :connection_name, :last_sync, :db_size, :latency, :version) do
        def initialize(
          connected: true,
          connection_name: "USPTO",
          last_sync: "2 min ago",
          db_size: "18.4M",
          latency: nil,
          version: "1.0"
        ) = super
      end

      # Sample data collections
      DEFAULT_STATUS = StatusInfo.new.freeze
      STATS = [
        Stat.new(value: "47", label: "new matches", highlight: true),
        Stat.new(value: "183", label: "this week"),
        Stat.new(value: "12", label: "active alerts"),
        Stat.new(value: "18.4M", label: "patents indexed")
      ].freeze

      ALERTS = [
        Alert.new(name: "Machine Learning — Image Recognition", count: 23, status: :active, time: "2m ago"),
        Alert.new(name: "Battery Technology — Solid State", count: 8, status: :active, time: "1h ago"),
        Alert.new(name: "Semiconductor — 3nm Process", count: 12, status: :active, time: "1h ago"),
        Alert.new(name: "Quantum Computing — Error Correction", count: 4, status: :active, time: "3h ago"),
        Alert.new(name: "Autonomous Vehicles — LIDAR", count: 0, status: :paused, time: "2d ago")
      ].freeze

      PATENTS = [
        Patent.new(
          id: "US20240401234",
          title: "Neural Network Architecture for Real-Time Object Detection in Autonomous Systems",
          assignee: "Google LLC",
          date: "2024-12-18",
          match: 94,
          cpc: "G06N, G06T"
        ),
        Patent.new(
          id: "US20240398765",
          title: "Convolutional Layer Optimization for Edge Device Deployment",
          assignee: "Apple Inc.",
          date: "2024-12-17",
          match: 89,
          cpc: "G06N"
        ),
        Patent.new(
          id: "US20240396543",
          title: "Multi-Modal Feature Extraction for Medical Imaging Analysis",
          assignee: "NVIDIA Corp",
          date: "2024-12-16",
          match: 87,
          cpc: "G06T, G16H"
        ),
        Patent.new(
          id: "US20240394321",
          title: "Attention Mechanism for Fine-Grained Image Classification",
          assignee: "Meta Platforms",
          date: "2024-12-15",
          match: 82,
          cpc: "G06N"
        ),
        Patent.new(
          id: "US20240392109",
          title: "Self-Supervised Learning for Unlabeled Image Datasets",
          assignee: "Microsoft Corp",
          date: "2024-12-14",
          match: 78,
          cpc: "G06N"
        )
      ].freeze

      LOG_ENTRIES = [
        LogEntry.new(time: "14:32:01", type: "SYNC", message: "ML Image Recognition: 23 new matches found"),
        LogEntry.new(time: "13:00:00", type: "MAIL", message: "Daily digest sent to user@company.com"),
        LogEntry.new(time: "11:45:23", type: "EDIT", message: "Battery Tech: keywords configuration updated"),
        LogEntry.new(time: "09:15:00", type: "SYNC", message: "USPTO database: 14,293 new patents indexed"),
        LogEntry.new(time: "YESTERDAY", type: "NEW", message: "Alert created: Quantum Computing"),
        LogEntry.new(time: "YESTERDAY", type: "PAUSE", message: "Alert paused: Autonomous Vehicles")
      ].freeze

      ACTIVITY_ITEMS = [
        ActivityItem.new(
          time: "2 minutes ago",
          parts: [
            TextPart.new(text: "Alert "),
            TextPart.new(text: "\"ML Image Recognition\"", highlight: true),
            TextPart.new(text: " found 23 new matching patents")
          ],
          tag: "New Results"
        ),
        ActivityItem.new(
          time: "1 hour ago",
          parts: [
            TextPart.new(text: "Daily digest sent for "),
            TextPart.new(text: "8 active alerts", highlight: true)
          ],
          tag: "Email Sent"
        ),
        ActivityItem.new(
          time: "3 hours ago",
          parts: [
            TextPart.new(text: "Alert "),
            TextPart.new(text: "\"Battery Tech\"", highlight: true),
            TextPart.new(text: " configuration updated")
          ],
          tag: "Modified"
        ),
        ActivityItem.new(
          time: "Yesterday",
          parts: [
            TextPart.new(text: "New alert created: "),
            TextPart.new(text: "\"Quantum Computing\"", highlight: true)
          ],
          tag: "Created"
        ),
        ActivityItem.new(
          time: "Yesterday",
          parts: [
            TextPart.new(text: "USPTO database sync completed — "),
            TextPart.new(text: "14,293", highlight: true),
            TextPart.new(text: " new patents indexed")
          ],
          tag: "System"
        ),
        ActivityItem.new(
          time: "2 days ago",
          parts: [
            TextPart.new(text: "Alert "),
            TextPart.new(text: "\"Autonomous Vehicles\"", highlight: true),
            TextPart.new(text: " paused by user")
          ],
          tag: "Paused"
        )
      ].freeze

      private

      def sample_stats = STATS
      def sample_alerts = ALERTS
      def sample_patents = PATENTS
      def sample_log_entries = LOG_ENTRIES
      def sample_activity_items = ACTIVITY_ITEMS
    end
  end
end
