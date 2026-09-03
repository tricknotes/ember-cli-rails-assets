# EmberCLI Rails - Assets

The `ember-cli-rails-assets` gem extends [`ember-cli-rails`][ember-cli-rails] to
enable rendering EmberCLI-generated JavaScript and CSS stylesheets into your
Rails application's layout HTML.

**This project and the behavior it supports is deprecated.**

Rendering EmberCLI applications with `render_ember_app` is the recommended,
actively supported method of serving EmberCLI applications.

However, for the sake of backwards compatibility, `ember-cli-rails-assets`
supports injecting the EmberCLI-generated assets into an existing Rails layout.

[ember-cli-rails]: https://github.com/tricknotes/ember-cli-rails

## Install

Add the following to your `Gemfile`:

```ruby
gem "ember-cli-rails-assets"
```

Then run `bundle install`:

```bash
$ bundle install
```

## Setup

To configure your project to use `ember-cli-rails`, follow the instructions
listed in the [`ember-cli-rails` README][README].

To configure a classic (Broccoli-based) Ember application to use
`ember-cli-rails-assets`, ensure its `ember-cli-build.js` includes the
following values:

```js
// frontend/ember-cli-build.js

module.exports = function(defaults) {
  var app = new EmberApp(defaults, {
    // http://ember-cli.com/user-guide/#application-configuration
    storeConfigInMeta: false,

    fingerprint: {
      // https://github.com/rickharrison/broccoli-asset-rev#options
      generateAssetMap: true,
    },
  });
};
```

[README]: https://github.com/tricknotes/ember-cli-rails#readme

### Vite-based applications

Vite-based applications (generated with `ember-cli >= 6.8`) require no build
configuration. For them, use `include_ember_script_tags` on its own: it emits
everything the application needs to boot — the configuration `<meta>` tag, the
stylesheet and `modulepreload` links, and the ES module script tags —
extracted from the generated `index.html`:

```erb
<%= include_ember_script_tags :frontend %>
```

When ember-cli-rails serves the application from Vite's development server in
`development`, `include_ember_script_tags` reads `index.html` from the server
instead of a build directory, and emits the startup tags with absolute URLs
pointing at the server. Nothing is built, so changes to the application are
picked up by reloading the page.

`include_ember_stylesheet_tags` only supports classic applications, and raises
an error when called for a Vite-based application.

## Mount

Mount the Ember application (in this example, the `frontend` application) to the
desired path:

```rb
# config/routes.rb

Rails.application.routes.draw do
  mount_ember_app :frontend, to: "/", controller: "ember#index"
end
```

Then, in the corresponding view, use the asset helpers:

```erb
<!-- app/views/ember/index.html.erb -->

<%= include_ember_script_tags :frontend %>
<%= include_ember_stylesheet_tags :frontend %>
```

## Caveats

### Mounting

If you're using the `include_ember` style helpers with a single-page Ember
application that defers routing to the Rails application, insert a call to
`mount_ember_assets` at the bottom of your routes file to serve the
EmberCLI-generated assets:

```rb
# config/routes.rb
Rails.application.routes.draw do
  mount_ember_assets :frontend, to: "/"
end
```

### Rendering

When injecting the EmberCLI-generated assets with the `include_ember_script_tags`
and `include_ember_stylesheet_tags` helpers to a path other than `"/"`, a
`<base>` tag must also be injected with a corresponding `href` value:

```erb
<base href="/">
<%= include_ember_script_tags :frontend %>
<%= include_ember_stylesheet_tags :frontend %>

<base href="/admin_panel/">
<%= include_ember_script_tags :admin_panel %>
<%= include_ember_stylesheet_tags :admin_panel %>
```

#### Rendering without `<base>` element

To render the asset elements without using a `<base>` element, pass the URL or
path to prepend:

```erb
<-- assuming Ember's assets are mounted to `"/"` -->
<%= include_ember_script_tags :frontend, prepend: "/" %>
<%= include_ember_stylesheet_tags :frontend, prepend: "/" %>

<%= include_ember_script_tags :admin_panel, prepend: "/" %>
<%= include_ember_stylesheet_tags :admin_panel, prepend: "/" %>
```

## EmberCLI support

This project supports:

* EmberCLI versions `>= 1.13.13` using the classic (Broccoli-based) build
* EmberCLI versions `>= 6.8` using the Vite-based build, with
  `include_ember_script_tags` only

## Ruby and Rails support

This project supports:

* Ruby versions `>= 2.1.0`
* Rails versions `>=4.1.x`.

## Contributing

See the [CONTRIBUTING] document.
Thank you, [contributors]!

  [CONTRIBUTING]: CONTRIBUTING.md
  [contributors]: https://github.com/tricknotes/ember-cli-rails-assets/graphs/contributors

## License

Open source templates are Copyright (c) 2015 Sean Doyle.
It contains free software that may be redistributed
under the terms specified in the [LICENSE] file.

[LICENSE]: /LICENSE.txt

## About

ember-cli-rails was originally created by
[Pavel Pravosud][rwz] and
[Jonathan Jackson][rondale-sc].

ember-cli-rails-assets was extracted from ember-cli-rails is maintained by
[Sean Doyle][seanpdoyle] and [Ryunosuke Sato][tricknotes].

[rwz]: https://github.com/rwz
[rondale-sc]: https://github.com/rondale-sc
[seanpdoyle]: https://github.com/seanpdoyle
[tricknotes]: https://github.com/tricknotes
