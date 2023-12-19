Not a javascript developer. these are notes so I remember how to work with docusaurus

### Pages:

- we can create pages in javascript, typescript or markdown
- pages are created in src/pages directory
- pages are independent pages that we want to create like about us page or contact us
  or a show case or a landing or index and so forth
- if we use javascript or typescript the pages are created using react.
- we need to import layout from docusaurus module and wrap the react component in it
  otherwise the page component will have no style
- markdown pages always use the style from theme layout from docusaurus

- the routes for page will be like below

```
/src/pages/index.js → [baseUrl]
/src/pages/foo.js → [baseUrl]/foo
/src/pages/foo/test.js → [baseUrl]/foo/test
/src/pages/foo/index.js → [baseUrl]/foo/
```

- to create page components we can create the file in 2 ways either create a component.js
  with component code in it or create a component directory that has an index.js or index.tsx
  with component code in it. with the latter option we can put other files for that component
  in that directory like css styles

Add a `/src/pages/support.js` file
Create a `/src/pages/support/` directory and a `/src/pages/support/index.js` file.

The latter is preferred as it has the benefits of letting you put files related to the page within
that directory. For example, a CSS module file `styles.module.css` with styles meant to only be
used on the "Support" page.

By default, any Markdown or JavaScript file or component directory starting with \_ will be ignored and no
routes will be created for that file (see the exclude option).

### Docs:

- docusaurus has a docs plugin that allows us to create documentation. plugin has sidebar and
  version feature.
- to change docs plugin config go to `docusaurus.config.ts > presets` and change the options there.
we can even change the base pass of the docs plugin and put it as root
- to create documentation pages we need to create markdown files and put them in `/docs` directory
- Note that all files prefixed with an underscore (_) under the docs directory are treated as 
"partial" pages and will be ignored by default. partial pages can be imported by doc pages
- in markdown we can add attributes at the top of each file. there are some attributes that docusaurus
uses and can be defined in page like this

```markdown
---
id: doc-with-tags
title: A doc with tags
slug: /docs/route-of-doc-page
tags:
  - Demo
  - Getting started
---

```

**doc page id:** Every document has a unique id. By default, a document id is the name of the document (without the extension) relative to the root docs directory.

For example, the ID of greeting.md is greeting, and the ID of guide/hello.md is guide/hello.

```markdown
website # Root directory of your site
└── docs
   ├── greeting.md
   └── guide
      └── hello.md
```

However, the last part of the id can be defined by the user in the front matter. For example, if guide/hello.md's content is defined as below, its final id is guide/part1.

**slug:** By default, a document's URL location is its file path relative to the docs folder. Use the slug front matter to change a document's URL.

For example, suppose your site structure looks like this:

```
website # Root directory of your site
└── docs
    └── guide
        └── hello.md
```

By default hello.md will be available at `/docs/guide/hello`. You can change its URL location to `/docs/bonjour`:
```
---
slug: /bonjour
---
```
slug will be appended to the doc plugin's `routeBasePath`, which is `/docs` by default. See Docs-only mode for how to remove the `/docs` part from the URL.

- the sidebar of the docs will be auto generated base on the structure of the docs markdown pages we create. however we can customize them.