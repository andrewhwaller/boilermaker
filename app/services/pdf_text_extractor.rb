# frozen_string_literal: true

class PdfTextExtractor
  class ExtractionError < StandardError; end
  class PdftotextNotFound < ExtractionError; end

  UNICODE_REPLACEMENT_THRESHOLD = 0.05 # 5% replacement chars = garbled
  MIN_WORD_LENGTH_AVG = 2.0 # Average word length below this suggests character soup

  def initialize
    validate_pdftotext!
  end

  def extract(file_path)
    stdout, stderr, status = Open3.capture3("pdftotext", "-layout", "-enc", "UTF-8", file_path.to_s, "-")

    unless status.success?
      raise ExtractionError, "pdftotext failed (exit #{status.exitstatus}): #{stderr.strip}"
    end

    text = stdout.strip

    if text.empty?
      raise ExtractionError, "pdftotext produced empty output (likely scanned/image-only PDF)"
    end

    { text: text, quality: assess_quality(text) }
  end

  private

  def validate_pdftotext!
    _, _, status = Open3.capture3("which", "pdftotext")
    unless status.success?
      raise PdftotextNotFound, "pdftotext not found. Install poppler-utils: brew install poppler"
    end
  end

  def assess_quality(text)
    return :low_quality if high_replacement_char_density?(text)
    return :low_quality if character_soup?(text)
    :good
  end

  def high_replacement_char_density?(text)
    replacement_count = text.count("\uFFFD")
    total = text.length.to_f
    return false if total.zero?
    (replacement_count / total) > UNICODE_REPLACEMENT_THRESHOLD
  end

  def character_soup?(text)
    words = text.scan(/\b\w+\b/)
    return false if words.length < 100 # Too short to judge
    avg_length = words.sum(&:length).to_f / words.length
    avg_length < MIN_WORD_LENGTH_AVG
  end
end
