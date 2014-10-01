# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

desc 'list available JSON API routes'
task :api_routes => :environment do
  puts api_routes.values.map { |section| section * "\n" + "\n" } * "\n"
end

namespace :doc do
  YARD::Rake::YardocTask.new

  desc 'create app documentation'
  task :dns_api => :environment do
    File.open("docs/APIRoutes.md", "w") do |file|
      file.puts '# DNSAPI API Routes',
        '## Intro',
        'These routes can be used for automated interaction.',
        'See the model documentation for available resource attributes.',
        '### Example:',
        %Q{\
      curl https://dns.example.com/records.json       \\
        --user username:pw                            \\ 
        -H "Content-Type: application/json"           \\
        -X POST                                       \\
        -d '{"record": {                              \\
          "domain_id": "<DOMAIN-ID>",                 \\
          "name": "<RECORD-NAME>",                    \\
          "type": "TXT",                              \\
          "content": "<RECORD-CONTENT>"               \\
        }}'}
      api_routes.each_pair do |section, section_routes|
        file.puts "## #{section[1..-1].capitalize}"
        file.puts
        file.puts section_routes.map { |r| "    #{r}" }
        file.puts
      end
    end

    Rake::Task['doc:yard'].invoke
  end
end

def api_routes
  Rails.application.routes.routes.inject({}) do |hash, route|
    path_array  = route.optimized_path
    section     = path_array.take(2).join

    unless section =~ /\A\/(?:rails|assets|dashboard|logout|locale)?\z/ ||
      path_array[1] != route.defaults[:controller] ||
      %w(new edit delete clone import).include?(path_array.last)
      path = path_array.map { |e| e.is_a?(Symbol) ? ":#{e}" : e }.join
      hash[section] ||= []
      hash[section] << "#{route.verb.to_s[/[[:upper:]]+/]}\t#{path}"
    end

    hash
  end
end
