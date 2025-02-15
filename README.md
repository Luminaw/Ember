# Ember

A fast static site generator written in Elixir.

## Features

- Lightning-fast site generation
- Markdown rendering
- Lots of customizability


## Installation

1. Ensure you have Elixir installed on your system
2. Clone this repository:
```bash
git clone https://github.com/Luminaw/ember.git
cd ember
```
3. Install dependencies:
```bash
mix deps.get
```

## Usage

### Development Server

```bash
mix ember.server
```

Visit `http://localhost:4000` to view your site.

## Roadmap

- [ ] RSS feed support
- [ ] Sort by tags
- [x] Delay access to posts until date
- [ ] Ability to update on webhook from repo
- [ ] Proper user configuration
- [ ] Documentation
- [ ] Full server side Caching
- [ ] Full CI/CD and testing
- [ ] Codeblocks syntax highlighting

## Development

### Prerequisites

- Elixir 1.14 or later
- Erlang/OTP 25 or later

## Acknowledgments

- Phoenix Framework
- YamlElixir
- HtmlSanitizeEx