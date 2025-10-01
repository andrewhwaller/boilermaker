# File System Structure

## Application Structure

```
boilermaker/
├── app/
│   ├── components/              # Phlex components
│   │   ├── application_component.rb
│   │   ├── shared/             # Shared UI components
│   │   ├── layouts/            # Layout components
│   │   └── theme_toggle.rb     # Component examples
│   ├── controllers/            # Rails controllers
│   │   ├── application_controller.rb
│   │   └── home_controller.rb
│   ├── models/                 # ActiveRecord models
│   ├── views/                  # Phlex view classes (not ERB)
│   ├── javascript/
│   │   ├── controllers/        # Stimulus controllers
│   │   └── application.js
│   ├── assets/
│   │   └── stylesheets/        # CSS and Tailwind
│   └── helpers/                # Rails helpers
├── config/                     # Rails configuration
├── db/                         # Database files and migrations
├── test/                       # Test files
│   ├── components/            # Phlex component tests
│   ├── controllers/           # Controller tests
│   ├── models/               # Model tests
│   └── system/               # System tests with Capybara
├── docs/                      # Project documentation
│   ├── plans/                # Implementation plans
│   ├── requirements/         # Requirements documents
│   └── stack/               # External library docs
└── .claude/                  # Claude Code configuration
    ├── agents/              # Sub-agent definitions
    └── commands/            # Custom commands
```

## Key Locations

- **Components**: `/app/components/` - All Phlex view components
- **Controllers**: `/app/controllers/` - Rails controllers
- **Models**: `/app/models/` - ActiveRecord models
- **Stimulus**: `/app/javascript/controllers/` - Client-side behavior
- **Styles**: `/app/assets/stylesheets/` - CSS and Tailwind
- **Tests**: `/test/` - All test files organized by type
- **Plans**: `/docs/plans/` - Implementation specifications
- **Claude Config**: `/.claude/` - Agent and command definitions