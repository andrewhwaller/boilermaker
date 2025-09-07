namespace :daisyui do
  desc "Generate prebuilt DaisyUI themes list based on Boilermaker config"
  task prebuilt: :environment do
    light_cfg = Boilermaker::Config.theme_light_name.to_s.strip
    dark_cfg  = Boilermaker::Config.theme_dark_name.to_s.strip
    light = Boilermaker::Themes::BUILTINS.include?(light_cfg) ? light_cfg : nil
    dark  = Boilermaker::Themes::BUILTINS.include?(dark_cfg)  ? dark_cfg  : nil
    # Fallbacks if either side is custom/blank
    light ||= "light"
    dark  ||= "dark"

    # Write plugin options to include only these themes.
    path = Rails.root.join("app", "assets", "tailwind", "daisyui.prebuilt.css")
    File.write(path, <<~CSS)
      @plugin "./daisyui.js" {
        /* Prebuilt DaisyUI themes to include in the build.
           Generated from config/boilermaker.yml (ui.theme.light/dark). */
        themes: #{[ light, dark ].uniq.join(', ')};
      }
    CSS

    begin
      Rails.logger.info("[daisyui:prebuilt] Wrote #{path} with themes: #{[ light, dark ].uniq.join(', ')}")
    rescue
      puts "[daisyui:prebuilt] Wrote #{path} with themes: #{[ light, dark ].uniq.join(', ')}"
    end
  end
end

# Ensure the prebuilt list is generated before assets:precompile when available
begin
  if defined?(Rake::Task) && Rake::Task.task_defined?("assets:precompile")
    Rake::Task["assets:precompile"].enhance([ "daisyui:prebuilt" ])
  end
rescue
  # no-op if assets:precompile is not defined in this environment
end
