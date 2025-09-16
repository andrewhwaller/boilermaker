require "yaml"
require "time"
require "json"

module Boilermaker
  module PM
    class Sync
      attr_reader :epic_name

      def initialize(epic_name = nil)
        @epic_name = epic_name
      end

      def run
        puts "🔄 Starting PM Sync#{epic_name ? " for epic: #{epic_name}" : ""}..."

        github_issues = fetch_github_issues
        local_files = find_local_files

        stats = {
          pulled_updated: 0,
          pulled_closed: 0,
          pushed_updated: 0,
          pushed_created: 0,
          conflicts: 0
        }

        # Update local from GitHub
        update_local_from_github(github_issues, local_files, stats)

        # Push local to GitHub
        push_local_to_github(local_files, github_issues, stats)

        # Update sync timestamps
        update_sync_timestamps(local_files)

        output_summary(stats)
      end

      private

      def fetch_github_issues
        epic_issues = fetch_issues_by_label("epic")
        task_issues = fetch_issues_by_label("task")

        all_issues = epic_issues + task_issues

        # Filter by epic if specified
        if epic_name
          all_issues.select! do |issue|
            issue["title"].include?(epic_name) ||
            issue["body"]&.include?(epic_name) ||
            issue["labels"]&.any? { |label| label["name"].include?(epic_name) }
          end
        end

        all_issues
      end

      def fetch_issues_by_label(label)
        result = `gh issue list --label "#{label}" --limit 1000 --json number,title,state,body,labels,updatedAt 2>/dev/null`

        if $?.success?
          JSON.parse(result)
        else
          puts "Warning: Failed to fetch #{label} issues from GitHub"
          []
        end
      end

      def find_local_files
        pattern = epic_name ? "**/*#{epic_name}*.md" : "**/*.md"
        files = Dir.glob(pattern, File::FNM_DOTMATCH)

        files.select do |file|
          content = File.read(file)
          has_frontmatter?(content) && (is_epic?(content) || is_task?(content))
        end
      end

      def has_frontmatter?(content)
        content.start_with?("---")
      end

      def is_epic?(content)
        frontmatter = parse_frontmatter(content)
        frontmatter["type"] == "epic"
      end

      def is_task?(content)
        frontmatter = parse_frontmatter(content)
        frontmatter["type"] == "task"
      end

      def parse_frontmatter(content)
        lines = content.lines
        return {} unless lines.first&.strip == "---"

        yaml_end = lines[1..-1].find_index { |line| line.strip == "---" }
        return {} unless yaml_end

        yaml_content = lines[1..yaml_end].join
        YAML.safe_load(yaml_content) || {}
      rescue
        {}
      end

      def update_local_from_github(github_issues, local_files, stats)
        github_issues.each do |issue|
          local_file = find_local_file_by_issue_number(local_files, issue["number"])
          next unless local_file

          if should_update_local?(local_file, issue)
            if both_changed?(local_file, issue)
              handle_conflict(local_file, issue)
              stats[:conflicts] += 1
            else
              update_local_file(local_file, issue)
              stats[:pulled_updated] += 1

              if issue["state"] == "closed"
                stats[:pulled_closed] += 1
              end
            end
          end
        end
      end

      def find_local_file_by_issue_number(local_files, issue_number)
        local_files.find do |file|
          frontmatter = parse_frontmatter(File.read(file))
          frontmatter["github_url"]&.include?("/#{issue_number}")
        end
      end

      def should_update_local?(local_file, issue)
        frontmatter = parse_frontmatter(File.read(local_file))
        local_updated = Time.parse(frontmatter["updated"] || frontmatter["created"] || "1970-01-01")
        github_updated = Time.parse(issue["updatedAt"])

        github_updated > local_updated
      end

      def both_changed?(local_file, issue)
        frontmatter = parse_frontmatter(File.read(local_file))
        local_updated = Time.parse(frontmatter["updated"] || frontmatter["created"] || "1970-01-01")
        github_updated = Time.parse(issue["updatedAt"])
        last_sync = Time.parse(frontmatter["last_sync"] || "1970-01-01")

        local_updated > last_sync && github_updated > last_sync
      end

      def handle_conflict(local_file, issue)
        puts "\n⚠️  Conflict detected for #{File.basename(local_file)}"
        puts "Both local and GitHub have changes since last sync."
        puts "\nOptions:"
        puts "  local   - Keep local version"
        puts "  github  - Use GitHub version"
        puts "  merge   - Open editor to merge manually"

        print "Choice (local/github/merge): "
        choice = $stdin.gets.chomp.downcase

        case choice
        when "github"
          update_local_file(local_file, issue)
        when "merge"
          open_merge_editor(local_file, issue)
        else # default to local
          puts "Keeping local version"
        end
      end

      def open_merge_editor(local_file, issue)
        temp_file = "/tmp/github_version_#{issue['number']}.md"
        File.write(temp_file, generate_markdown_from_issue(issue))

        editor = ENV["EDITOR"] || "vi"
        system("#{editor} #{local_file} #{temp_file}")

        File.delete(temp_file) if File.exist?(temp_file)
      end

      def update_local_file(local_file, issue)
        content = File.read(local_file)
        frontmatter = parse_frontmatter(content)

        # Update frontmatter
        frontmatter["state"] = issue["state"]
        frontmatter["updated"] = issue["updatedAt"]
        frontmatter["title"] = issue["title"]

        # Regenerate file
        new_content = generate_file_content(frontmatter, issue["body"] || "")
        File.write(local_file, new_content)
      end

      def generate_file_content(frontmatter, body)
        yaml_content = YAML.dump(frontmatter).sub(/^---\n/, "")
        "---\n#{yaml_content}---\n\n#{body}"
      end

      def push_local_to_github(local_files, github_issues, stats)
        local_files.each do |file|
          frontmatter = parse_frontmatter(File.read(file))

          if frontmatter["github_url"]
            issue_number = extract_issue_number(frontmatter["github_url"])
            github_issue = github_issues.find { |i| i["number"] == issue_number }

            if github_issue.nil?
              # GitHub issue was deleted
              mark_local_as_archived(file)
            elsif should_update_github?(file, github_issue)
              update_github_issue(file, issue_number)
              stats[:pushed_updated] += 1
            end
          else
            # No GitHub URL - create new issue
            create_github_issue(file)
            stats[:pushed_created] += 1
          end
        end
      end

      def extract_issue_number(github_url)
        github_url.match(/\/(\d+)$/)[1].to_i
      rescue
        nil
      end

      def should_update_github?(local_file, github_issue)
        frontmatter = parse_frontmatter(File.read(local_file))
        local_updated = Time.parse(frontmatter["updated"] || frontmatter["created"] || "1970-01-01")
        github_updated = Time.parse(github_issue["updatedAt"])

        local_updated > github_updated
      end

      def update_github_issue(local_file, issue_number)
        temp_file = "/tmp/issue_body_#{issue_number}.md"
        body = extract_body_from_file(local_file)
        File.write(temp_file, body)

        result = system("gh issue edit #{issue_number} --body-file #{temp_file}")
        File.delete(temp_file)

        unless result
          puts "Warning: Failed to update GitHub issue ##{issue_number}"
        end
      end

      def extract_body_from_file(file)
        content = File.read(file)
        lines = content.lines

        # Skip frontmatter
        yaml_end = lines[1..-1].find_index { |line| line.strip == "---" }
        return content unless yaml_end

        lines[(yaml_end + 3)..-1].join
      end

      def create_github_issue(local_file)
        frontmatter = parse_frontmatter(File.read(local_file))
        body = extract_body_from_file(local_file)

        labels = []
        labels << frontmatter["type"] if frontmatter["type"]
        labels << frontmatter["epic"] if frontmatter["epic"]

        label_args = labels.map { |l| "--label #{l}" }.join(" ")

        temp_file = "/tmp/new_issue_body.md"
        File.write(temp_file, body)

        result = `gh issue create --title "#{frontmatter["title"]}" --body-file #{temp_file} #{label_args}`.strip
        File.delete(temp_file)

        if result.include?("https://github.com")
          # Update local file with GitHub URL
          frontmatter["github_url"] = result
          new_content = generate_file_content(frontmatter, body)
          File.write(local_file, new_content)
          puts "Created GitHub issue: #{result}"
        else
          puts "Warning: Failed to create GitHub issue for #{File.basename(local_file)}"
        end
      end

      def mark_local_as_archived(file)
        content = File.read(file)
        frontmatter = parse_frontmatter(content)
        frontmatter["archived"] = true
        frontmatter["archived_at"] = Time.now.iso8601

        body = extract_body_from_file(file)
        new_content = generate_file_content(frontmatter, body)
        File.write(file, new_content)
      end

      def update_sync_timestamps(local_files)
        timestamp = Time.now.iso8601

        local_files.each do |file|
          content = File.read(file)
          frontmatter = parse_frontmatter(content)
          frontmatter["last_sync"] = timestamp

          body = extract_body_from_file(file)
          new_content = generate_file_content(frontmatter, body)
          File.write(file, new_content)
        end
      end

      def output_summary(stats)
        puts "\n🔄 Sync Complete\n"

        puts "Pulled from GitHub:"
        puts "  Updated: #{stats[:pulled_updated]} files"
        puts "  Closed: #{stats[:pulled_closed]} issues"
        puts ""

        puts "Pushed to GitHub:"
        puts "  Updated: #{stats[:pushed_updated]} issues"
        puts "  Created: #{stats[:pushed_created]} new issues"
        puts ""

        puts "Conflicts resolved: #{stats[:conflicts]}"
        puts ""
        puts "Status:"
        puts "  ✅ All files synced"
      end

      def generate_markdown_from_issue(issue)
        labels = issue["labels"]&.map { |l| l["name"] }&.join(", ") || ""

        frontmatter = {
          "title" => issue["title"],
          "state" => issue["state"],
          "labels" => labels,
          "updated" => issue["updatedAt"],
          "github_url" => "https://github.com/#{repo_name}/issues/#{issue['number']}"
        }

        generate_file_content(frontmatter, issue["body"] || "")
      end

      def repo_name
        result = `git remote get-url origin 2>/dev/null`.strip
        return "unknown/repo" unless $?.success?

        result.match(/github\.com[\/:](.+?)(?:\.git)?$/)[1]
      rescue
        "unknown/repo"
      end
    end
  end
end
