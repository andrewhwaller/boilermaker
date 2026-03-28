# frozen_string_literal: true

module Chunkable
  extend ActiveSupport::Concern

  CHUNK_SIZE = 2000     # ~500 tokens
  CHUNK_OVERLAP = 200   # ~50 tokens
  SEPARATORS = [ "\n\n", "\n", ". ", " " ].freeze
  HEADING_PATTERN = /\A[A-Z][A-Za-z0-9\s:,\-]{2,80}$/
  PAGE_BOUNDARY_PATTERN = /\f/

  class_methods do
    def chunk_text(text, chunk_size: CHUNK_SIZE, overlap: CHUNK_OVERLAP)
      return [] if text.nil? || text.strip.empty?

      # Clean text: strip page headers/footers, normalize whitespace
      cleaned = strip_page_artifacts(text)

      # Split into chunks recursively
      chunks = recursive_split(cleaned, SEPARATORS, chunk_size, overlap)

      # Attach section headings
      attach_headings(chunks, cleaned)
    end

    private

    def strip_page_artifacts(text)
      # Remove form feeds and repeated short lines at page boundaries
      pages = text.split(PAGE_BOUNDARY_PATTERN)
      pages.map { |page| strip_header_footer(page) }.join("\n\n")
    end

    def strip_header_footer(page)
      lines = page.lines
      return page if lines.length < 5

      # Remove first and last lines if they look like headers/footers
      # (short lines, often just page numbers or repeated headers)
      first = lines.first.strip
      last = lines.last.strip

      lines.shift if first.length < 60 && first.match?(/\A[\d\s\-\.]+\z|\A[A-Z][a-z]+\s+\d+\z/)
      lines.pop if last.length < 60 && last.match?(/\A[\d\s\-\.]+\z|\A[A-Z][a-z]+\s+\d+\z/)

      lines.join
    end

    def recursive_split(text, separators, chunk_size, overlap)
      return [ { content: text.strip, position: 0 } ] if text.strip.length <= chunk_size

      separator = separators.first
      remaining_separators = separators[1..]

      segments = text.split(separator)

      chunks = []
      current = ""

      segments.each do |segment|
        candidate = current.empty? ? segment : "#{current}#{separator}#{segment}"

        if candidate.length > chunk_size && !current.empty?
          chunks << current.strip
          # Start new chunk with overlap from end of previous
          overlap_text = current.last(overlap)
          current = "#{overlap_text}#{separator}#{segment}"
        else
          current = candidate
        end
      end

      chunks << current.strip unless current.strip.empty?

      # If any chunk is still too large and we have more separators, recurse
      if remaining_separators.any?
        chunks = chunks.flat_map do |chunk|
          if chunk.length > chunk_size
            recursive_split(chunk, remaining_separators, chunk_size, overlap)
              .map { |c| c.is_a?(Hash) ? c[:content] : c }
          else
            [ chunk ]
          end
        end
      end

      chunks.each_with_index.map do |content, idx|
        { content: content, position: idx }
      end
    end

    def attach_headings(chunks, original_text)
      lines = original_text.lines

      # Build a heading map: line positions to heading text
      headings = []
      lines.each_with_index do |line, idx|
        stripped = line.strip
        if stripped.match?(HEADING_PATTERN) && stripped == stripped.upcase || stripped.match?(/\A\d+\.?\s+[A-Z]/)
          headings << { text: stripped, position: idx }
        end
      end

      chunks.each do |chunk|
        # Find the most recent heading that appears before this chunk's content
        chunk_start = original_text.index(chunk[:content][0..50]) || 0
        relevant_heading = headings.select { |h|
          original_text.lines[0...h[:position]].join.length <= chunk_start
        }.last

        chunk[:section_heading] = relevant_heading&.dig(:text)
      end

      chunks
    end
  end
end
