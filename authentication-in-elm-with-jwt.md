---
layout: post
title: "Build an App in Elm with JWT Authentication and an API"
description: "Explore building an app in the functional, reactive front-end language Elm, complete with an API and JWT authentication."
date: 2016-06-08
author:
  name: Kim Maida
  url: http://twitter.com/KimMaida
  mail: kim@kmaida.io
  avatar: https://en.gravatar.com/userimage/20807150/4c9e5bd34750ec1dcedd71cb40b4a9ba.png   
tags:
- jwt
- elm
- javascript
- authentication
---

---

**TL;DR:** TBD...

---

All JavaScript app developers are likely familiar with this scenario: we implement logic, deploy our code, and then in QA (or worse, production) we encounter a runtime error! Maybe it was something we forgot to write a test for, or it's an obscure edge case we didn't foresee. Either way, when it comes to business logic in production code, we often spend post-launch with the vague threat of errors hanging over our heads.

Enter [Elm](http://www.elm-lang.org): a [functional](https://www.smashingmagazine.com/2014/07/dont-be-scared-of-functional-programming/), [reactive](https://gist.github.com/staltz/868e7e9bc2a7b8c1f754) front-end programming language that compiles to JavaScript, making it great for web applications that run in the browser. Elm's compiler presents us with friendly error messages _before_ runtime, thereby eliminating RTEs.

## Why Elm?

Elm's creator [Evan Czaplicki](https://github.com/evancz) [positions Elm with several strong concepts](http://www.elmbark.com/2016/03/16/mainstream-elm-user-focused-design), but we'll touch on two in particular: gradual learning and usage-driven design. _Gradual learning_ is the idea that we can be productive with the language before diving deep. As we use Elm, we are able to gradually learn via development and build up our skillset, but we are not hampered in the beginner stage by a high barrier to entry. _Usage-driven design_ emphasizes starting with the minimimum viable solution and iteratively building on it, but Evan points out that it's best to keep it simple, and the minimum viable solution is often enough by itself.

Okay, we're interested! If we head over to the [Elm site](http://www.elm-lang.org), we're greeted with a nice featureset highlighting several points, including "No runtime exceptions", "Blazing fast rendering", and "Smooth JavaScript interop". But what does all of this boil down to when we're writing real code? Let's take a look.

## Building an Elm web app

We're going to build a simple Elm application that will call an API to retrieve random Chuck Norris quotes. We'll also be able to register, log in, and access protected quotes with JSON Web Tokens. In doing so, we'll learn Elm basics like how to compose an app with a view and a model and how to update application state. In addition, we'll cover common real-world requirements, like implementing `HTTP` and using JavaScript interop to store data in `localStorage`.

If you're [familiar with JavaScript but new to Elm](http://elm-lang.org/docs/from-javascript), the language might look a little strange at first--but once we start building, we'll learn how the [Elm Architecture](http://guide.elm-lang.org/architecture/index.html), [types](http://guide.elm-lang.org/types), and [clean syntax](http://elm-lang.org/docs/syntax) can really streamline development.

## Setup and Installation

The full source code for our finished app can be [cloned here](https://github.com/YiMihi/elm-app-jwt-api).

We're going to use [Gulp](http://gulpjs.com) to build and serve our application locally and [NodeJS](https://nodejs.org/en) to serve our API and install dependencies through the Node Package Manager (`npm`). If you don't already have Node and Gulp installed, please head over to their respective websites and follow instructions for download and installation. 

We'll also need the API. Clone the [NodeJS JWT Authentication sample API](https://github.com/auth0-blog/nodejs-jwt-authentication-sample) repository and follow the README to get it running.

### Installing and Configuring Elm

To install Elm globally, run the following command:

```bash
npm install -g elm
```

Once Elm is successfully installed, we need to set up our project's configuration. This is done with an `elm-package.json` file:

```js
// elm-package.json

{
    "version": "0.1.0",
    "summary": "Build an App in Elm with JWT Authentication and an API",
    "repository": "https://github.com/YiMihi/elm-app-jwt-api.git",
    "license": "MIT",
    "source-directories": [
        "src",
        "dist"
    ],
    "exposed-modules": [],
    "dependencies": {
        "elm-lang/core": "4.0.1 <= v < 5.0.0",
        "elm-lang/html": "1.0.0 <= v < 2.0.0",
        "evancz/elm-http": "3.0.1 <= v < 4.0.0",
        "rgrempel/elm-http-decorators": "1.0.2 <= v < 2.0.0"
    },
    "elm-version": "0.17.0 <= v < 0.18.0"
}
```

We'll be using Elm v0.17 in this tutorial. The `elm-version` here is restricted to minor point releases of 0.17. There are large breaking changes between versions 0.17 and 0.16 and we can likely expect the same for 0.18, hence the restriction to 0.17.x in the `elm-package.json`.

Now that we've declared our Elm dependencies, we can install them by using the command:

```bash
elm package install
```

When prompted, confirm installation of the dependencies. Once everything has installed successfully, an `elm-stuff` folder will live at the root of your project.

### Build Tools

Now we have Node, Gulp, Elm, and the API ready. Let's set up our project's build configuration. Create a JSON file called `package.json`, which should live at our project's root:

```js
// package.json

...

  "dependencies": {},
  "devDependencies": {
    "gulp": "^3.9.0",
    "gulp-connect": "^4.0.0",
    "gulp-elm": "^0.4.4",
    "gulp-plumber": "^1.1.0",
    "gulp-util": "^3.0.7"
  }

...
```

Once the `package.json` file is in place, we can run the following command from the project root to install the Node dependencies we specified:

```bash
npm install
```

Next, we need to create a `gulpfile.js` at the root:

```js
// gulpfile.js

var gulp = require('gulp');
var elm = require('gulp-elm');
var gutil = require('gulp-util');
var plumber = require('gulp-plumber');
var connect = require('gulp-connect');

// File paths
var paths = {
  dest: 'dist',
  elm: 'src/*.elm',
  static: 'src/*.{html,css}'
};

// Init Elm
gulp.task('elm-init', elm.init);
 
// Compile Elm to HTML
gulp.task('elm', ['elm-init'], function(){
    return gulp.src(paths.elm)
        .pipe(plumber())
        .pipe(elm())
        .pipe(gulp.dest(paths.dest));
});

// Move static assets to dist
gulp.task('static', function() {
    return gulp.src(paths.static)
        .pipe(plumber())
        .pipe(gulp.dest(paths.dest));
});

// Watch for changes and compile
gulp.task('watch', function() {
    gulp.watch(paths.elm, ['elm']);
    gulp.watch(paths.static, ['static']);
});

// Local server
gulp.task('connect', function() {
    connect.server({
        root: 'dist',
        port: 3000
    });
});

// Main gulp tasks
gulp.task('build', ['elm', 'static']);
gulp.task('default', ['connect', 'build', 'watch']);
```

The `gulpfile.js` sets up tasks that that will compile our Elm code and copy necessary assets to a `/dist` folder as well as run a local server where we can view our application in a browser. Our development files should be located in a `/src` folder. Please create the `/dist` and `/src` folders at the root of the project. If all steps have been followed so far, our file structure should look like this:

```
/dist
/elm-stuff
/node_modules
/src
gulpfile.js
package.json
```

That's it for the build process. We're ready to start writing our Elm app. When the `gulp` default task is running, we'll be able to access our app in the browser at [http://localhost:3000](http://localhost:3000).

---

Image assets:

<!--![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step1.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step2.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step3a.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step3b.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step4a.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step4b.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step5a.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step5b-6.jpg)-->