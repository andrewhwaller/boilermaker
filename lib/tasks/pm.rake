require_relative '../boilermaker/pm/sync'

namespace :pm do
  desc "Sync project management files with GitHub issues"
  task :sync, [:epic_name] => :environment do |t, args|
    epic_name = args[:epic_name]
    
    # Check if gh CLI is available
    unless system('which gh > /dev/null 2>&1')
      puts "❌ Error: GitHub CLI (gh) is not installed or not in PATH"
      puts "Install with: brew install gh"
      exit 1
    end
    
    # Check if authenticated
    unless system('gh auth status > /dev/null 2>&1')
      puts "❌ Error: Not authenticated with GitHub CLI"
      puts "Run: gh auth login"
      exit 1
    end
    
    # Check if in git repository
    unless system('git rev-parse --git-dir > /dev/null 2>&1')
      puts "❌ Error: Not in a git repository"
      exit 1
    end
    
    begin
      sync = Boilermaker::PM::Sync.new(epic_name)
      sync.run
    rescue StandardError => e
      puts "❌ Error during sync: #{e.message}"
      puts e.backtrace.first(5).join("\n") if ENV['DEBUG']
      exit 1
    end
  end
  
  desc "Show help for PM commands"
  task :help do
    puts <<~HELP
      📋 Project Management Commands
      
      Available commands:
        rake pm:sync              - Sync all epics and tasks with GitHub
        rake pm:sync[epic_name]   - Sync specific epic with GitHub
        rake pm:help              - Show this help
      
      Prerequisites:
        • GitHub CLI installed: brew install gh
        • Authenticated: gh auth login
        • In git repository with GitHub remote
      
      File Structure:
        epics/epic-name.md        - Epic files
        tasks/task-name.md        - Task files
        
      Frontmatter Format:
        ---
        title: "Issue Title"
        type: "epic" | "task"
        state: "open" | "closed"
        created: "2024-01-01T12:00:00Z"
        updated: "2024-01-01T12:00:00Z"
        github_url: "https://github.com/owner/repo/issues/123"
        ---
    HELP
  end
end