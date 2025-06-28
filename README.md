# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# Boilermaker

An Rails application template with a modern stack.

## Features

- **Ruby on Rails 8** with all the latest goodies
- **Phlex Views** for a pure Ruby approach to HTML generation
- **Tailwind CSS** for utility-first styling
- **SQLite** with Litestream for simple, reliable databases
- **Solid Queue** for background job processing
- **Authentication** with sessions and two-factor auth
- **Phlex View Scaffolding** for rapid prototyping with consistent architecture

## Phlex View Scaffolding

This boilerplate includes a custom Phlex scaffolding system that generates Phlex views instead of ERB for Rails scaffolds.

### Quick Setup (Recommended)

1. Uncomment these lines in `config/application.rb`:

```ruby
config.generators do |g|
  g.template_engine :phlex_scaffold
end
```

2. Use regular Rails scaffolding, and get Phlex views automatically:

```bash
bin/rails generate scaffold Post title:string content:text published:boolean
```

### Alternative: Manual Generator

If you prefer to keep ERB as the default, you can use the custom generator directly:

```bash
bin/rails generate phlex:scaffold Post title:string content:text published:boolean
```

For complete documentation, see [docs/phlex_scaffolding.md](docs/phlex_scaffolding.md).

## Getting Started

1. Clone this repository
2. Run `bin/setup` to install dependencies
3. Run `bin/dev` to start the development server
4. Start building your application with Phlex scaffolding!

## Documentation

- [Phlex Architecture](docs/phlex_architecture.md) - Understanding the view layer
- [Phlex Scaffolding](docs/phlex_scaffolding.md) - Rapid prototyping with Phlex
