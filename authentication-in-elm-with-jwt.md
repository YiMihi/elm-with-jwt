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

_TODO: another paragraph or two here, possibly about The Elm Architecture, the compiler's friendly errors, and/or immutability / statelessness_

Okay, we're interested! If we head over to the [Elm site](http://www.elm-lang.org), we're greeted with a nice featureset highlighting several points, including "No runtime exceptions", "Blazing fast rendering", and "Smooth JavaScript interop". But what does all of this boil down to when we're writing real code? Let's take a look.

## Building an Elm web app

We're going to build a simple Elm application that will call an API to retrieve random Chuck Norris quotes. We'll also be able to register, log in, and access protected quotes with JSON Web Tokens. In doing so, we'll learn Elm basics like how to compose an app with a view and a model and how to update application state. In addition, we'll cover common real-world requirements, like implementing `HTTP` and using JavaScript interop to store data in `localStorage`.

If you're [familiar with JavaScript but new to Elm](http://elm-lang.org/docs/from-javascript), the language might look a little strange at first--but once we start building, we'll learn how the [Elm Architecture](http://guide.elm-lang.org/architecture/index.html), [types](http://guide.elm-lang.org/types), and [clean syntax](http://elm-lang.org/docs/syntax) can really streamline development.

## Setup and Installation

The full source code for our finished app can be [cloned here](https://github.com/YiMihi/elm-app-jwt-api).

We're going to use [Gulp](http://gulpjs.com) to build and serve our application locally and [NodeJS](https://nodejs.org/en) to serve our API and install dependencies through the Node Package Manager (`npm`). If you don't already have Node and Gulp installed, please head over to their respective websites and follow instructions for download and installation. 

_Note: Webpack is an alternative to Gulp. If you're interested in trying a very customizable webpack build in the future for larger Elm projects, check out [elm-webpack-loader](https://github.com/rtfeldman/elm-webpack-loader)._

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

We'll be using Elm v0.17 in this tutorial. The `elm-version` here is restricted to minor point releases of 0.17. There are breaking changes between versions 0.17 and 0.16 and we can likely expect the same for 0.18, hence the restriction to 0.17.x in the `elm-package.json`.

Now that we've declared our Elm dependencies, we can install them by using the command:

```bash
elm package install
```

When prompted, confirm installation of the dependencies. Once everything has installed successfully, an `/elm-stuff` folder will live at the root of your project. This folder contains all of the Elm package dependencies we specified in our `elm-package.json`.

#### Elm REPL

_TODO: what Elm REPL is and how to use it_

### Build Tools

Now we have Node, Gulp, Elm, and the API installed. Let's set up our project's build configuration. Create and populate a `package.json`, which should live at our project's root:

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

Next, we need to create a `gulpfile.js`:

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

The `gulpfile.js` sets up the tasks that will compile our Elm code, copy files to a `/dist` folder when they are saved, and run a local server where we can view our application in a browser. We will primarily be using the default `gulp` task during development of our application. 

Our development files should be located in a `/src` folder. Please create the `/dist` and `/src` folders at the root of the project. If all steps have been followed so far, our file structure should look like this:

```
/dist
/elm-stuff
/node_modules
/src
elm-package.json
gulpfile.js
package.json
```

That's it for the build process. When the `gulp` default task is running, we'll be able to access our app in the browser at [http://localhost:3000](http://localhost:3000).

### Syntax Highlighting

There's one more thing we should do before we start writing Elm, and that is to grab a plugin for our code editor that will provide syntax highlighting and inline compile error messaging. There are plugins available for many popular editors. I like to use [VS Code](https://code.visualstudio.com/Download) with [vscode-elm](https://github.com/sbrink/vscode-elm), but you can [download the plugin for your editor of choice here](http://elm-lang.org/install) and install it. With that done, we're ready to begin coding our Elm app.

## Hello, Chuck Norris

As mentioned, we're going to build an application that does a bit more than echo "Hello world". We're going to connect to an API, register, log in, and make authenticated requests, but we'll start simple. We'll begin by displaying a button that will append a string to our model each time it's clicked.

When we've got everything hooked up, this is what the first phase of our app will look like:

![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step1.jpg)

We'll put all files directly in the `/src` folder. Gulp will compile the Elm code and move the static files to the `/dist` folder where we'll view them in the browser.

Let's fire up our Gulp task in a command window. This will start a local server and begin watching for files to compile and copy to `/dist`:

```bash
gulp
```

_Note:_ Since Gulp is compiling Elm for us, if we have compile errors they will show up in the command prompt / terminal window. If you have one of the Elm plugins installed in your editor, they should also show up inline in your code.

### HTML

Let's start by creating a basic `index.html`:

```html
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title>Chuck Norris Quoter</title>
        <script src="Main.js"></script>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
        <link rel="stylesheet" href="styles.css">
    </head>
    
    <body>
    </body>
    
    <script>
        var app = Elm.Main.fullscreen();
    </script>
</html>   
```

We're titling our app "Chuck Norris Quoter" and loading a JavaScript file called `Main.js`. Elm compiles to JavaScript and this is the file that will be built from our compiled Elm code. 

We've also added links to stylesheets. We'll start with [Bootstrap](http://www.getbootstrap.com) and load the CSS from a [CDN](https://www.bootstrapcdn.com) to keep it simple. The second stylesheet is a local `styles.css` file. In it, we'll put a few helper overrides.

The `<body>` can be empty. The Elm app will be dynamically written to it, and the last thing we'll do in our `index.html` is tell Elm to load our application. The Elm module we're going to export is called `Main` (from `Main.js`), so this is what our index file should use.

### CSS

Next, let's create the `styles.css` file:

```css
/* styles.css */

.container {
    margin: 1em auto;
    max-width: 600px;
}
blockquote {
    margin: 1em 0;
}
.jumbotron {
    margin: 2em auto;
    max-width: 400px;
}
.jumbotron h2 {
    margin-top: 0;
}
.jumbotron .help-block {
    font-size: 14px;
}
```

As you can see, for the most part these are simple Bootstrap overrides to make the app display a little nicer.

Our file structure should now look like this:

```
/dist
/elm-stuff
/node_modules
/src
  |-- index.html
  |-- styles.css
elm-package.json  
gulpfile.js
package.json
```

### Introduction to Elm with Main.elm

Now we're ready to start writing Elm.

Create a file in the `/src` folder called `Main.elm`. This is what we'll be building for the first step:

```js
-- Main.elm

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)

main : Program Never
main = 
    Html.program 
        { init = init 
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }
    
{- 
    MODEL
    * Model type 
    * Initialize model with empty values
-}

type alias Model =
    { quote : String 
    }
    
init : (Model, Cmd Msg)
init =
    ( Model "", Cmd.none )

{-
    UPDATE
    * Messages
    * Update case
-}

type Msg = GetQuote

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetQuote ->
            ( { model | quote = model.quote ++ "A quote! " }, Cmd.none )
            
{-
    VIEW
-}

view : Model -> Html Msg
view model =
    div [ class "container" ] [
        h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
        , p [ class "text-center" ] [
            button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote!" ]
        ]
        -- Blockquote with quote
        , blockquote [] [ 
            p [] [text model.quote] 
        ]
    ]            
```

Let's go through this code in more detail. 

**If you're already familiar with Elm, you can likely skip ahead to the next step. If Elm is brand new to you, keep reading: we'll run through an introduction to the [Elm Architecture](http://guide.elm-lang.org/architecture) and Elm's language syntax by thoroughly breaking down this code.** Make sure you have a good grasp of this section before moving on; the next sections will assume an understanding of the following syntax and concepts.

```js
import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
```

At the top of our app file, we need to import dependencies. We expose the `Html` package to the application for use and then declare `Html.App` as `Html` for brevity when referencing it. Because we'll be writing a view function, we will expose `Html.Events` (for click events) and `Html.Attributes` to use IDs, types, classes, and other HTML element attributes.

```js
main : Program Never
main = 
    Html.program 
        { init = init 
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }
```

`main : Program Never` is a [type annotation](https://github.com/elm-guides/elm-for-js/blob/master/How%20to%20Read%20a%20Type%20Annotation.md). This annotation says "`main` has type `Program` and should `Never` expect a flags argument". If this doesn't make a ton of sense yet, hang tight--we'll be covering more type annotations throughout the development of our app.

Every Elm project defines `main` as a program. There are a few program candidates, including `beginnerProgram`, `program`, and `programWithFlags`. Initially, we'll use `main = Html.program`.

The next thing we'll do is start our app with a record that references an `init` function, an `update` function, and a `view` function. We'll create these functions shortly.

`subscriptions` might look a little strange at first. [Subscriptions](http://www.elm-tutorial.org/en/03-subs-cmds/01-subs.html) listen for external input and we won't be using any in the Chuck Norris Quoter so we don't really need a named function here. Elm does not have a concept of `null` or `undefined` and it is expecting functions as values for all items in this particular record. Therefore, this is an anonymous function that simply declares there are no subscriptions. 

Here's a breakdown of the syntax. `\` begins an anonymous function. `_` represents an argument that is discarded, so `\_` is stating "this is an unnamed function that doesn't use arguments". `->` signifies the body of the function. `subscriptions = \_ -> ...` in JavaScript would look like this:

```js
// JS
subscriptions = function() { ... }
```

(Keeping this in mind, what would an anonymous function _with_ an argument look like? Answer: `\x -> ...`)

Next up are the model and the `init` function:

```js
{- 
    MODEL
    * Model type 
    * Initialize model with empty values
-}

type alias Model =
    { quote : String 
    }
    
init : (Model, Cmd Msg)
init =
    ( Model "", Cmd.none )
```

The first block is just a multi-line comment. Comments in Elm are represented like this:

```js
{-
	This is a
	multi-line
	comment
-}

-- Single line comment
```

Now we'll create a `type alias` called `Model`. 

```js
type alias Model =
    { quote : String 
    }
```

A [type alias](http://guide.elm-lang.org/types/type_aliases.html) is a definition for use in type annotations. Consider the following example:

```js
someRecord : Bool -> { somestr : String, someint : Int, somebool : Bool }

...

type alias RecordModel =
	{ somestr : String
	, someint : Int
	, somebool : Bool
	}
	
someRecord : Bool -> RecordModel
``` 

The first and second examples of `someRecord` are synonymous. The first one has the type defined long-hand, and the second is referencing the type alias to define `someRecord`'s type. The advantage of this is clear when you need longer types that can become unwieldy to read in sequence, particularly if they're used in multiple places.

Moving on, we now have a `type alias` for `Model`. We expect a record with a property of `quote` that has `String` value. We've mentioned [records](http://elm-lang.org/docs/records) a few times now, so we'll expand on them briefly: records look similar to objects in JavaScript. However, records in Elm are immutable: they hold labeled data but do not have inheritance or methods. Elm's functional paradigm uses persistent data structures so "updating the model" returns a new model with only the changed data copied. This doesn't manipulate the original model. If you're coming from a JavaScript background but haven't used something like React/Redux, you're probably still familiar with libraries like [lodash](http://lodash.com) that use functional JS. If you think about how lodash is used, this should seem familiar.

Now we've come to the `init` function that we referenced in our `main` program:

```js
init : (Model, Cmd Msg)
init =
    ( Model "", Cmd.none )
```

The type annotation for `init` basically means "`init` has type tuple containing record defined in Model type alias, and a command for an effect with an update message". That's a mouthful--and we'll be encountering additional type annotations that look similar but have more context, so they'll be easier to understand. What we should take away from this type annotation is that we're returning a [tuple](http://guide.elm-lang.org/core_language.html#tuples) (an ordered list of values of potentially varying types). So for now, let's concentrate on the `init` function.

Functions in Elm are defined with a name followed by a space and any arguments (separated by spaces), an `=`, and the body of the function indented on a newline. There are no parentheses, braces, `function` or `return` keywords. This might feel sparse at first, but the clean syntax speeds development. This is most noticeable when switching to another language after Elm--I start to realize how much _time_ I spend writing syntax.

Returning a tuple is the easiest way to get multiple results from a function. The first element in the tuple declares the initial values of the Model record. Strings are denoted with double quotes, so we are defining `{ quote = "" }` on initialization. The second element is `Cmd.none` because we're not sending a command (yet!). 

```js
{-
    UPDATE
    * Messages
    * Update case
-}

type Msg = GetQuote

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetQuote ->
            ( { model | quote = model.quote ++ "A quote! " }, Cmd.none )
```

The next vital piece of the Elm Architecture (we've covered model already) is update. There are a few new things here.

First we have `type Msg = GetQuote`. This is a union type. [Union types](https://dennisreimann.de/articles/elm-data-structures-union-type.html) provide a way to represent types that have structures other than the "usual", like `String`, `Bool`, etc. This says `type Msg` could be any of the following values, with the possibilities separated by pipes `|`. Right now we only have `GetQuote`, but we'll add more later.

Now that we have a union type definition, we need a function that will handle the union type using a `case` expression. We are calling this function `update`, because its purpose is to update the model, representing the current application state.

The `update` function has a type annotation that says "`update` takes a message as an argument and a model argument and returns a tuple containing a model and a command for an effect with an update message". 

This is the first time we've seen `->` in a type annotation, so let's take a moment to look at that. A series of items separated by `->` in a type annotation represent argument types until the last one, which is the return type. The reason that we don't use a different notation to indicate the return has to do with currying. In a nutshell, _currying_ means that if you don't pass all the arguments to a function, another function will be returned that accepts whatever arguments are still needed. You can [learn more](http://www.lambdacat.com/road-to-elm-currying-the-unknown/) [about currying](https://en.wikipedia.org/wiki/Currying) [elsewhere](http://veryfancy.net/blog/curried-form-in-elm-functions).

As just discussed above in our assessment of the type annotation, the `update` function accepts two arguments: a message and a model. If the `msg` is `GetQuote`, we'll return a tuple that updates the `quote` to append `"A quote! "` to the existing string value. The second element in the tuple is currently `Cmd.none`. Later, we will change this to execute the command to get a random quote from the API. The case expression models possible user interactions.

The syntax for updating properties of a record is:

```js
{ recordName | property = updatedValue, property2 = updatedValue2 }
```

We now have the logic in place for our application. How will we display the UI? We need to render a view.

```js
{-
    VIEW
-}

view : Model -> Html Msg
view model =
    div [ class "container" ] [
        h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
        , p [ class "text-center" ] [
            button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote!" ]
        ]
        -- Blockquote with quote
        , blockquote [] [ 
            p [] [text model.quote] 
        ]
    ]
``` 

The type annotation for the `view` function reads, "`view` accepts model as an argument and returns HTML with a message". We've seen `Msg` a few places before, and now we have defined its union type. A message in Elm is a function that notifies the `update` method that a command was completed. 

The `view` function describes the rendered view based on the application state, which is represented by the model. The code for the `view` resembles `HTML` but it's actually composed of functions that correspond to virtual DOM nodes and pass lists as parameters. When the model is updated, the view function executes again. The previous virtual DOM is diffed against the next and the minimal set of updates necessary are run.

The structure of the HTML functions does somewhat resemble HTML, so it's fairly intuitive to write. The first list argument passed to each node function are the attribute functions with values passed as arguments. The second list contains the contents of the element. For example:

```js
button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote!" ]
```

This `button` function's first argument is a list. The first item in that list is the `class` function passing the string of classes we want to display. The second item in the list is an `onClick` function: `GetQuote`. We set this up earlier to update the model and append "A quote!" each time it's executed. The next list argument is the contents of the button. We'll give the `text` function an argument of "Grab a quote!".

Last, we want to display the quote text. We'll do this with a `blockquote` with a `p` inside it, passing the `model.quote` to the paragraph's `text` function.

---

...

That was a lot of detail, but we're now set on the syntax and basic structure of an Elm app. We'll be moving faster from here on. 

---

Image assets (placement TBD):



<!--![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step2.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step3a.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step3b.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step4a.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step4b.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step5a.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step5b-6.jpg)-->