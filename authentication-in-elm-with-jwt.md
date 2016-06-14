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

**TL;DR:** We can write statically typed, functional, reactive SPAs on the front end with [Elm](http://www.elm-lang.org). Elm's compiler prevents runtime errors and compiles to JavaScript, making it an excellent choice for clean, speedy development. Learn how to write your first Elm app that calls an API and implements authentication with JSON Web Tokens.

---

All JavaScript app developers are likely familiar with this scenario: we implement logic, deploy our code, and then in QA (or worse, production) we encounter a runtime error! Maybe it was something we forgot to write a test for, or it's an obscure edge case we didn't foresee. Either way, when it comes to business logic in production code, we often spend post-launch with the vague threat of errors hanging over our heads.

Enter [Elm](http://www.elm-lang.org): a [functional](https://www.smashingmagazine.com/2014/07/dont-be-scared-of-functional-programming/), [reactive](https://gist.github.com/staltz/868e7e9bc2a7b8c1f754) front-end programming language that compiles to JavaScript, making it great for web applications that run in the browser. Elm's compiler presents us with friendly error messages _before_ runtime, thereby eliminating RTEs.

## Why Elm?

Elm's creator [Evan Czaplicki](https://github.com/evancz) [positions Elm with several strong concepts](http://www.elmbark.com/2016/03/16/mainstream-elm-user-focused-design), but we'll touch on two in particular: gradual learning and usage-driven design. _Gradual learning_ is the idea that we can be productive with the language before diving deep. As we use Elm, we are able to gradually learn via development and build up our skillset, but we are not hampered in the beginner stage by a high barrier to entry. _Usage-driven design_ emphasizes starting with the minimimum viable solution and iteratively building on it, but Evan points out that it's best to keep it simple, and the minimum viable solution is often enough by itself.

If we head over to the [Elm site](http://www.elm-lang.org), we're greeted with an attractive featureset highlighting "No runtime exceptions", "Blazing fast rendering", and "Smooth JavaScript interop". But what does this boil down to when writing real code? Let's take a look.

## Building an Elm web app

We're going to build a small Elm application that will call an API to retrieve random Chuck Norris quotes. We'll also be able to register, log in, and access protected quotes with JSON Web Tokens. In doing so, we'll learn Elm basics like how to compose an app with a view and a model and how to update application state. In addition, we'll cover common real-world requirements like implementing HTTP and using JavaScript interop to store data in local storage.

If you're [familiar with JavaScript but new to Elm](http://elm-lang.org/docs/from-javascript), the language might look a little strange at first--but once we start building, we'll learn how the [Elm Architecture](http://guide.elm-lang.org/architecture/index.html), [types](http://guide.elm-lang.org/types), and [clean syntax](http://elm-lang.org/docs/syntax) can really streamline development. This tutorial is structured to help JavaScript developers get started with Elm without assuming previous experience with other functional or strongly typed languages. 

## Setup and Installation

The full source code for our finished app can be [cloned on GitHub here](https://github.com/YiMihi/elm-app-jwt-api).

We're going to use [Gulp](http://gulpjs.com) to build and serve our application locally and [NodeJS](https://nodejs.org/en) to serve our API and install dependencies through the Node Package Manager (npm). If you don't already have Node and Gulp installed, please visit their respective websites and follow instructions for download and installation. 

_Note: Webpack is an alternative to Gulp. If you're interested in trying a very customizable webpack build in the future for larger Elm projects, check out [elm-webpack-loader](https://github.com/rtfeldman/elm-webpack-loader)._

We also need the API. Clone the [NodeJS JWT Authentication sample API](https://github.com/auth0-blog/nodejs-jwt-authentication-sample) repository and follow the README to get it running.

### Installing and Configuring Elm

To install Elm globally, run the following command:

```bash
npm install -g elm
```

Once Elm is successfully installed, we need to set up our project's configuration. This is done with an `elm-package.json`:

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

We'll be using Elm v0.17 in this tutorial. The `elm-version` here is restricted to minor point releases of 0.17. There are breaking changes between versions 0.17 and 0.16 and we can likely expect the same for 0.18.

Now that we've declared our Elm dependencies, we can install them:

```bash
elm package install
```

Once everything has installed, an `/elm-stuff` folder will live at the root of your project. This folder contains all of the Elm dependencies we specified in our `elm-package.json`.

### Build Tools

Now we have Node, Gulp, Elm, and the API installed. Let's set up our build configuration. Create and populate a `package.json`, which should live at our project's root:

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

Once the `package.json` file is in place, install the Node dependencies:

```bash
npm install
```

Next, create a `gulpfile.js`:

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

The default `gulp` task will compile Elm, watch and copy files to a `/dist` folder, and run a local server where we can view our application at [http://localhost:3000](http://localhost:3000).

Our development files should be located in a `/src` folder. Please create the `/dist` and `/src` folders at the root of the project. Our file structure now looks like this:

```
/dist
/elm-stuff
/node_modules
/src
elm-package.json
gulpfile.js
package.json
```

### Syntax Highlighting

There's one more thing we should do before we start writing Elm, and that is to grab a plugin for our code editor to provide syntax highlighting and inline compile error messaging. There are plugins available for many popular editors. I like to use [VS Code](https://code.visualstudio.com/Download) with [vscode-elm](https://github.com/sbrink/vscode-elm), but you can [download a plugin for your editor of choice here](http://elm-lang.org/install). With syntax highlighting installed, we're ready to begin coding our Elm app.

## Building the Chuck Norris Quoter App

We're going to build an app that does more than echo "Hello world". We're going to connect to an API, register, log in, and make authenticated requests--but we'll start simple. First we'll display a button that appends a string to our model each time it's clicked.

Once we've got things running, our app should look like this:

![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step1.jpg)

Let's fire up our Gulp task. This will start a local server and begin watching for file changes:

```bash
gulp
```

_Note: Since Gulp is compiling Elm for us, if we have compile errors they will show up in the command prompt / terminal window. If you have one of the Elm plugins installed in your editor, they should also show up inline in your code._

### HTML

We'll start by creating a basic `index.html`:

```html
<!-- index.html -->

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

We're loading a JavaScript file called `Main.js`. Elm compiles to JavaScript and this is the file that will be built from our compiled Elm code. 

We'll also load the [Bootstrap CSS](https://www.bootstrapcdn.com) and a local `styles.css` file for a few helper overrides.

Finally we'll use JS to tell Elm to load our application. The Elm module we're going to export is called `Main` (from `Main.js`).

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

We're ready to start writing Elm. Create a file in the `/src` folder called `Main.elm`. This is what we'll be building for the first step:

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

**If you're already familiar with Elm, you can skip ahead. If Elm is brand new to you, keep reading: we'll introduce The Elm Architecture and Elm's language syntax by thoroughly breaking down this code.** Make sure you have a good grasp of this section before moving on; the next sections will assume an understanding of the syntax and concepts.

```js
import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
```

At the top of our app file, we need to import dependencies. We expose the `Html` package to the application for use and then declare `Html.App` as `Html`. Because we'll be writing a view function, we will expose `Html.Events` and `Html.Attributes` to use click and input events, IDs, classes, and other element attributes.

Everything we're going to write is part of **The Elm Architecture**. In brief, this refers to the basic pattern of Elm application logic. It consists of `Model` (application state), `Update` (way to update the application state), and `View` (render the application state as HTML). You can read more about [The Elm Architecture in Elm's guide](http://guide.elm-lang.org/architecture).

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

`main : Program Never` is a [type annotation](https://github.com/elm-guides/elm-for-js/blob/master/How%20to%20Read%20a%20Type%20Annotation.md). This annotation says "`main` has type `Program` and should `Never` expect a flags argument". If this doesn't make a ton of sense yet, hang tight--we'll be covering more type annotations throughout our app.

Every Elm project defines `main` as a program. There are a few program candidates, including `beginnerProgram`, `program`, and `programWithFlags`. Initially, we'll use `main = Html.program`.

Next we'll start our app with a record that references an `init` function, an `update` function, and a `view` function. We'll create these functions shortly.

`subscriptions` may look strange at first. [Subscriptions](http://www.elm-tutorial.org/en/03-subs-cmds/01-subs.html) listen for external input and we won't be using any in the Chuck Norris Quoter so we don't need a named function here. Elm does not have a concept of `null` or `undefined` and it's expecting functions as values in this record. This is an anonymous function that declares there are no subscriptions. 

Here's a breakdown of the syntax. `\` begins an anonymous function. A backslash is used [because it resembles a lambda (λ)](https://en.wikipedia.org/wiki/Anonymous_function). `_` represents an argument that is discarded, so `\_` is an anonymous function that doesn't have arguments. `->` signifies the body of the function. `subscriptions = \_ -> ...` in JS would look like this:

```js
// JS
subscriptions = function() { ... }
```

(What would an anonymous function _with_ an argument look like? Answer: `\x -> ...`) 

Next up are the model type alias and the `init` function:

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

The first block is a multi-line comment. A single-line comment is represented like this:

```js
-- Single-line comment
```

Let's create a `type alias` called `Model`: 

```js
type alias Model =
    { quote : String 
    }
```

A [type alias](http://guide.elm-lang.org/types/type_aliases.html) is a definition for use in type annotations. In future type annotations, we can now say `Something : Model` and `Model` would be replaced by the contents of the type alias.

We expect a record with a property of `quote` that has `String` value. We've mentioned [records](http://elm-lang.org/docs/records) a few times, so we'll expand on them briefly: records look similar to objects in JavaScript. However, records in Elm are immutable: they hold labeled data but do not have inheritance or methods. Elm's functional paradigm uses persistent data structures so "updating the model" returns a new model with only the changed data copied.

Now we've come to the `init` function that we referenced in our `main` program:

```js
init : (Model, Cmd Msg)
init =
    ( Model "", Cmd.none )
```

The type annotation for `init` means "`init` returns a tuple containing record defined in Model type alias and a command for an effect with an update message". That's a mouthful--and we'll be encountering additional type annotations that look similar but have more context, so they'll be easier to understand. What we should take away from this type annotation is that we're returning a [tuple](http://guide.elm-lang.org/core_language.html#tuples) (an ordered list of values of potentially varying types). So for now, let's concentrate on the `init` function.

Functions in Elm are defined with a name followed by a space and any arguments (separated by spaces), an `=`, and the body of the function indented on a newline. There are no parentheses, braces, `function` or `return` keywords. This might feel sparse at first but hopefully you'll find the clean syntax speeds development.

Returning a tuple is the easiest way to get multiple results from a function. The first element in the tuple declares the initial values of the Model record. Strings are denoted with double quotes, so we're defining `{ quote = "" }` on initialization. The second element is `Cmd.none` because we're not sending a command (yet!). 

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

The next vital piece of the Elm Architecture is update. There are a few new things here.

First we have `type Msg = GetQuote`: this is a union type. [Union types](https://dennisreimann.de/articles/elm-data-structures-union-type.html) provide a way to represent types that have unusual structures (they aren't `String`, `Bool`, `Int`, etc). This says `type Msg` could be any of the following values. Right now we only have `GetQuote` but we'll add more later.

Now that we have a union type definition, we need a function that will handle this using a `case` expression. We're calling this function `update` because its purpose is to update the application state via the model.

The `update` function has a type annotation that says "`update` takes a message as an argument and a model argument and returns a tuple containing a model and a command for an effect with an update message". 

This is the first time we've seen `->` in a type annotation. A series of items separated by `->` represent argument types until the last one, which is the return type. The reason we don't use a different notation to indicate the return has to do with currying. In a nutshell, _currying_ means if you don't pass all the arguments to a function, another function will be returned that accepts whatever arguments are still needed. You can [learn more](http://www.lambdacat.com/road-to-elm-currying-the-unknown/) [about currying](https://en.wikipedia.org/wiki/Currying) [elsewhere](http://veryfancy.net/blog/curried-form-in-elm-functions).

The `update` function accepts two arguments: a message and a model. If the `msg` is `GetQuote`, we'll return a tuple that updates the `quote` to append `"A quote! "` to the existing value. The second element in the tuple is currently `Cmd.none`. Later, we'll change this to execute the command to get a random quote from the API. The case expression models possible user interactions.

The syntax for updating properties of a record is:

```js
{ recordName | property = updatedValue, property2 = updatedValue2 }
```

Elm uses `=` to set values. Colons `:` are reserved for type definitions. A `:` means "has type" so if we were to use them here, we would get a compiler error.

We now have the logic in place for our application. How will we display the UI? We need to render a view:

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

The type annotation for the `view` function reads, "`view` accepts model as an argument and returns HTML with a message". We've seen `Msg` a few places and now we've defined its union type. A command `Cmd` is a request for an effect to take place outside of Elm. A message `Msg` is a function that notifies the `update` method that a command was completed. The view needs to return HTML with the message outcome to display the updated UI.

The `view` function describes the rendered view based on the model. The code for `view` resembles HTML but is actually composed of functions that correspond to virtual DOM nodes and pass lists as arguments. When the model is updated, the view function executes again. The previous virtual DOM is diffed against the next and the minimal set of updates necessary are run.

The structure of the functions somewhat resembles HTML, so it's pretty intuitive to write. The first list argument passed to each node function contains attribute functions with arguments. The second list contains the contents of the element. For example:

```js
button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote!" ]
```

This `button`'s first argument is the attribute list. The first item in that list is the `class` function accepting the string of classes. The second item is an `onClick` function with `GetQuote`. The next list argument is the contents of the button. We'll give the `text` function an argument of "Grab a quote!".

Last, we want to display the quote text. We'll do this with a `blockquote` and `p`, passing `model.quote` to the paragraph's `text` function.

We now have all the pieces in place for the first phase of our app! We can view it at [http://localhost:3000](http://localhost:3000). Try clicking the "Grab a quote!" button a few times.

_Note: If the app didn't compile, Elm provides [compiler errors for humans](http://elm-lang.org/blog/compiler-errors-for-humans) in the console and in your editor if you're using an Elm plugin. Elm will not compile if there are errors! This is to avoid runtime exceptions._

That was a lot of detail, but now we're set on basic syntax and structure. We'll move on to build the features of our Chuck Norris Quoter app. 

### Calling the API

Now we're ready to fill in some of the blanks we left earlier. In several places we claimed in our type annotations that a command `Cmd` should be returned, but we returned `Cmd.none` instead. Now we'll replace those with the missing command. 

When this step is done, our application should look like this:

![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step2.jpg)

Clicking the button will call the API to get and display random Chuck Norris quotes. Make sure you have [the API](https://github.com/auth0-blog/nodejs-jwt-authentication-sample) running at [http://localhost:3001](http://localhost:3001) so it's accessible to our app.

Once we're successfully getting quotes, our `Main.elm` file will be:

```js
module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Http
import Task exposing (Task)

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
    * Initialize with a random quote
-}

type alias Model =
    { quote : String
    }
    
init : (Model, Cmd Msg)
init =
    ( Model "", fetchRandomQuoteCmd )
       
{-
    UPDATE
    * API routes
    * GET
    * Messages
    * Update case
-}

-- API request URLs
    
api : String
api =
     "http://localhost:3001/"    
    
randomQuoteUrl : String
randomQuoteUrl =    
    api ++ "api/random-quote"   

-- GET a random quote (unauthenticated)
    
fetchRandomQuote : Platform.Task Http.Error String
fetchRandomQuote =
    Http.getString randomQuoteUrl
    
fetchRandomQuoteCmd : Cmd Msg
fetchRandomQuoteCmd =
    Task.perform HttpError FetchQuoteSuccess fetchRandomQuote   

-- Messages

type Msg 
    = GetQuote
    | FetchQuoteSuccess String
    | HttpError Http.Error      

-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetQuote ->
            ( model, fetchRandomQuoteCmd )

        FetchQuoteSuccess newQuote ->
            ( { model | quote = newQuote }, Cmd.none )
            
        HttpError _ ->
            ( model, Cmd.none )  
                       
{-
    VIEW
    * Get a quote
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

The first thing we need to do is import the dependencies necessary for making HTTP requests:

```js
import Http
import Task exposing (Task)
```

[Http](http://package.elm-lang.org/packages/evancz/elm-http/3.0.1/Http) is self-explanatory. We also need [Task](http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Task). A [task](http://guide.elm-lang.org/error_handling/task.html) in Elm is similar to a promise in JS: tasks describe asynchronous operations that can succeed or fail.

Next we'll update our `init` function:

```js
init : (Model, Cmd Msg)
init =
    ( Model "", fetchRandomQuoteCmd )
```

Now instead of `Cmd.none` we have a command called `fetchRandomQuoteCmd`. A [command](http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Platform-Cmd#Cmd) is a way to tell Elm to do some effect (like HTTP). We're commanding the application to fetch a random quote from the API on initialization. We'll define the `fetchRandomQuoteCmd` function shortly.

```js
{-
    UPDATE
    * API routes
    * GET
    * Messages
    * Update case
-}

-- API request URLs
    
api : String
api =
     "http://localhost:3001/"    
    
randomQuoteUrl : String
randomQuoteUrl =    
    api ++ "api/random-quote"   

-- GET a random quote (unauthenticated)
    
fetchRandomQuote : Platform.Task Http.Error String
fetchRandomQuote =
    Http.getString randomQuoteUrl
    
fetchRandomQuoteCmd : Cmd Msg
fetchRandomQuoteCmd =
    Task.perform HttpError FetchQuoteSuccess fetchRandomQuote
``` 

We've added some code to our update section. First we'll store the API routes. 

The Chuck Norris API returns unauthenticated random quotes as strings, not JSON. Let's create a function called `fetchRandomQuote`. The type annotation declares that this function is a task that either fails with an error or succeeds with a string. We can use the [`Http.getString`](http://package.elm-lang.org/packages/evancz/elm-http/3.0.1/Http#getString) method to make the HTTP request with the API route as an argument.

HTTP is something that happens outside of Elm. A command is needed to request the effect and a message is needed to notify the update that the effect was completed and to deliver its results.

We'll do this in `fetchRandomQuoteCmd`. This function's type annotation declares that it returns a command with a message. [`Task.perform`](http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Task#perform) is a command that tells the runtime to execute a task. Tasks can fail or succeed so we need to pass three arguments to `Task.perform`: a message for failure (`HttpError`), a message for success (`FetchQuoteSuccess`), and what task to perform (`fetchRandomQuote`). 

`HttpError` and `FetchQuoteSuccess` are messages that don't exist yet, so let's create them:

```js
-- Messages

type Msg 
    = GetQuote
    | FetchQuoteSuccess String
    | HttpError Http.Error      

-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetQuote ->
            ( model, fetchRandomQuoteCmd )

        FetchQuoteSuccess newQuote ->
            ( { model | quote = newQuote }, Cmd.none )
            
        HttpError _ ->
            ( model, Cmd.none )
```            

We add these two new messages to the `Msg` union type and annotate the types of their arguments. `FetchQuoteSuccess` accepts a string that contains the new Chuck Norris quote from the API and `HttpError` accepts an [`Http.Error`](http://package.elm-lang.org/packages/evancz/elm-http/3.0.1/Http#Error). These are the possible success / fail results of the task.

Next we add these cases to the `update` function and declare what we want returned in the `(Model, Cmd Msg)` tuple. We also need to update the `GetQuote` tuple to fetch a quote from the API. We'll change `GetQuote` to return the current model and issue the command to fetch a random quote, `fetchRandomQuoteCmd`.

`FetchQuoteSuccess`'s argument is the new quote string. We want to update the model with this. There are no commands to execute here, so we will declare the second element of the tuple `Cmd.none`.

`HttpError`'s argument is `Http.Error` but we aren't going to do anything special with this. For the sake of brevity, we'll handle API errors when we get to authentication but not for getting unauthenticated quotes. Since we're discarding this argument, we can pass `_` to `HttpError`. This will return a tuple that sends the model in its current state and no command. You may want to handle errors here on your own after completing the provided code.

It's important to remember that the `update` function's type is `Msg -> Model -> (Model, Cmd Msg)`. This means that all branches of the `case` statement _must_ return the same type. If any branch does not return a tuple with a model and a command, a compiler error will occur.

Nothing changes in the `view`. We altered the `GetQuote` onClick function logic, but everything that we've written in the HTML works fine with our updated code. Try it out!

#### Aside: Reading Compiler Type Errors

If you've been following along and writing your own code, you may have encountered Elm's compiler errors. Though they are very readable, type mismatch messages can sometimes seem ambiguous.

Here's a small breakdown of some things you may see:

```js
String -> a
```

A lowercase variable `a` means "anything could go here". The above means "takes a string as an argument and returns anything".

`[1, 2, 3]` has a type of `List number`: a list that only contains numbers. `[]` is type `List a`: Elm infers that this is a list that could contain anything.

Elm always infers types. If we've declared type definitions, Elm checks its inferences against our definitions. We're defining types upfront in most places in our app. It's best practice to define the types at the top-level at a minimum. If Elm finds a type mismatch, it will tell us what type it has inferred. Resolving type mismatches can be one of the larger challenges to developers coming from a loosely typed language like JS (without Typescript), so it's worth spending time getting comfortable with this. 

### Register a User

We're now getting quotes from the API. We also need registration so users can be issued [JSON Web Tokens](https://auth0.com/learn/json-web-tokens) with which to access protected quotes. We'll create a form that submits a `POST` request to the API to create a new user and return a token.

![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step3a.jpg)

After the user has registered, we'll display a welcome message:

![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step3b.jpg)

Here's the complete `Main.elm` code for this step:

```js
module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import String

import Http
import Task exposing (Task)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)

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
    * Initialize with a random quote
-}

type alias Model =
    { username : String
    , password : String
    , token : String
    , quote : String
    , errorMsg : String
    }
    
init : (Model, Cmd Msg)
init =
    ( Model "" "" "" "" "", fetchRandomQuoteCmd )
    
{-
    UPDATE
    * API routes
    * GET and POST
    * Encode request body 
    * Decode responses
    * Messages
    * Update case
-}

-- API request URLs
    
api : String
api =
     "http://localhost:3001/"    
    
randomQuoteUrl : String
randomQuoteUrl =    
    api ++ "api/random-quote"
    
registerUrl : String
registerUrl =
    api ++ "users"       

-- GET a random quote (unauthenticated)
    
fetchRandomQuote : Platform.Task Http.Error String
fetchRandomQuote =
    Http.getString randomQuoteUrl
    
fetchRandomQuoteCmd : Cmd Msg
fetchRandomQuoteCmd =
    Task.perform HttpError FetchQuoteSuccess fetchRandomQuote     

-- Encode user to construct POST request body (for Register and Log In)
    
userEncoder : Model -> Encode.Value
userEncoder model = 
    Encode.object 
        [ ("username", Encode.string model.username)
        , ("password", Encode.string model.password) 
        ]          

-- POST register / login request
    
authUser : Model -> String -> Task Http.Error String
authUser model apiUrl =
    { verb = "POST"
    , headers = [ ("Content-Type", "application/json") ]
    , url = apiUrl
    , body = Http.string <| Encode.encode 0 <| userEncoder model
    }
    |> Http.send Http.defaultSettings
    |> Http.fromJson tokenDecoder    
    
authUserCmd : Model -> String -> Cmd Msg    
authUserCmd model apiUrl = 
    Task.perform AuthError GetTokenSuccess <| authUser model apiUrl
    
-- Decode POST response to get token
    
tokenDecoder : Decoder String
tokenDecoder =
    "id_token" := Decode.string         
    
-- Messages

type Msg 
    = GetQuote
    | FetchQuoteSuccess String
    | HttpError Http.Error
    | AuthError Http.Error
    | SetUsername String
    | SetPassword String
    | ClickRegisterUser
    | GetTokenSuccess String

-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetQuote ->
            ( model, fetchRandomQuoteCmd )

        FetchQuoteSuccess newQuote ->
            ( { model | quote = newQuote }, Cmd.none )

        HttpError _ ->
            ( model, Cmd.none )  

        AuthError error ->
            ( { model | errorMsg = (toString error) }, Cmd.none )  

        SetUsername username ->
            ( { model | username = username }, Cmd.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none )

        ClickRegisterUser ->
            ( model, authUserCmd model registerUrl )

        GetTokenSuccess newToken ->
            ( { model | token = newToken, errorMsg = "" } |> Debug.log "got new token", Cmd.none )  
                       
{-
    VIEW
    * Hide sections of view depending on authenticaton state of model
    * Get a quote
    * Register
-}

view : Model -> Html Msg
view model =
    let 
        -- Is the user logged in?
        loggedIn : Bool
        loggedIn =
            if String.length model.token > 0 then True else False 

        -- If the user is logged in, show a greeting; if logged out, show the login/register form
        authBoxView =
            let
                -- If there is an error on authentication, show the error alert
                showError : String
                showError = 
                    if String.isEmpty model.errorMsg then "hidden" else ""  

                -- Greet a logged in user by username
                greeting : String
                greeting =
                    "Hello, " ++ model.username ++ "!"

            in        
                if loggedIn then
                    div [id "greeting" ][
                        h3 [ class "text-center" ] [ text greeting ]
                        , p [ class "text-center" ] [ text "You have super-secret access to protected quotes." ]  
                    ] 
                else
                    div [ id "form" ] [
                        h2 [ class "text-center" ] [ text "Log In or Register" ]
                        , p [ class "help-block" ] [ text "If you already have an account, please Log In. Otherwise, enter your desired username and password and Register." ]
                        , div [ class showError ] [
                            div [ class "alert alert-danger" ] [ text model.errorMsg ]
                        ]
                        , div [ class "form-group row" ] [
                            div [ class "col-md-offset-2 col-md-8" ] [
                                label [ for "username" ] [ text "Username:" ]
                                , input [ id "username", type' "text", class "form-control", Html.Attributes.value model.username, onInput SetUsername ] []
                            ]    
                        ]
                        , div [ class "form-group row" ] [
                            div [ class "col-md-offset-2 col-md-8" ] [
                                label [ for "password" ] [ text "Password:" ]
                                , input [ id "password", type' "password", class "form-control", Html.Attributes.value model.password, onInput SetPassword ] []
                            ]    
                        ]
                        , div [ class "text-center" ] [
                            button [ class "btn btn-link", onClick ClickRegisterUser ] [ text "Register" ]
                        ] 
                    ]
                           
    in
        div [ class "container" ] [
            h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
            , p [ class "text-center" ] [
                button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote!" ]
            ]
            -- Blockquote with quote
            , blockquote [] [ 
                p [] [text model.quote] 
            ]
            , div [ class "jumbotron text-left" ] [
                -- Login/Register form or user greeting
                authBoxView
            ]
        ]
```

Starting with new imports:

```js
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
```

We'll be sending objects and receiving JSON now instead of just working with a string API response, so we need to be able to translate these from and to Elm records.

```js
{- 
    MODEL
    * Model type 
    * Initialize model with empty values
    * Initialize with a random quote
-}

type alias Model =
    { username : String
    , password : String
    , token : String
    , quote : String
    , errorMsg : String
    }
    
init : (Model, Cmd Msg)
init =
    ( Model "" "" "" "" "", fetchRandomQuoteCmd )
```

Our model needs to hold more data than just a quote now. We've added `username`, `password`, `token`, and `errorMsg` (to display any API errors from authentication).

We'll initialize our application with empty strings for all of the above.

```js
{-
    UPDATE
    * API routes
    * GET and POST
    * Encode request body 
    * Decode responses
    * Messages
    * Update case
-}

-- API request URLs  
    
...
    
registerUrl : String
registerUrl =
    api ++ "users"
```

The API route for `POST`ing new users is [http://localhost:3001/users](http://localhost:3001/users) so we'll create `registerUrl` to store this.
  
```js
-- Encode user to construct POST request body (for Register and Log In)
    
userEncoder : Model -> Encode.Value
userEncoder model = 
    Encode.object 
        [ ("username", Encode.string model.username)
        , ("password", Encode.string model.password) 
        ]          
```

The API expects the request body for registration and login to be a JavaScript object in string format that looks like this: `{ username: "string", password: "string" }`

An Elm record is not the same as a JavaScript object so we need to [encode](http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Json-Encode#encode) the applicable properties of our model before we can send them with the HTTP request. The `userEncoder` function utilizes [`Json.Encode.object`](http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Json-Encode#object) to take the model and return the encoded value.

```js
-- POST register / login request
    
authUser : Model -> String -> Task Http.Error String
authUser model apiUrl =
    { verb = "POST"
    , headers = [ ("Content-Type", "application/json") ]
    , url = apiUrl
    , body = Http.string <| Encode.encode 0 <| userEncoder model
    }
    |> Http.send Http.defaultSettings
    |> Http.fromJson tokenDecoder 
```    

We'll use a [fully specified HTTP request](http://package.elm-lang.org/packages/evancz/elm-http/3.0.1/Http#Request) this time as opposed to the simple `getString` used for the quote in the previous step. The same settings can be used for both register and login with the exception of the API route which we'll pass in an argument.

We'll call this effect function `authUser` (for "authenticate a user"). The type says "`authUser` takes model as an argument and a string as an argument and returns a task that fails with an error or succeeds with a string".

Let's take a closer look at these lines:

```js
...
	, body = Http.string <| Encode.encode 0 <| userEncoder model
    }
    |> Http.send Http.defaultSettings
    |> Http.fromJson tokenDecoder
```

`<|` and `|>` are aliases for function application to reduce parentheses. [`<|` is backward function application](http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Basics#%3C|). 

`body = Http.string <| Encode.encode 0 <| userEncoder model` takes the results of the last function and passes it as the last argument to the function on its left. Written with parentheses, the equivalent would be: `body = Http.string (Encode.encode 0 (userEncoder model))`

We'll run the `userEncoder` function to encode the request body. Then [`Json.Encode.encode`](http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Json-Encode#encode) converts the resulting value to a prettified string with no (`0`) indentation. Finally, we provide the resulting string as the request body with [`Http.String`](http://package.elm-lang.org/packages/evancz/elm-http/3.0.1/Http#string).

Next we have [forward function application performed with `|>`](http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Basics#|%3E) to send the HTTP request with default settings and then take the JSON result and decode it with a `tokenDecoder` function that we'll create in a moment.

We now have our `authUser` effect so we need to create an `authUserCmd` command. This should look familiar from fetching quotes earlier. We're also passing the API route as an argument. We'll create the `AuthError` and `GetTokenSuccess` messages shortly.

```js
authUserCmd : Model -> String -> Cmd Msg    
authUserCmd model apiUrl = 
    Task.perform AuthError GetTokenSuccess <| authUser model apiUrl
```

Because `authUser` takes arguments, we'll use `<|` to tell the app that the `model` and `apiUrl` belong to `authUser` and not to `Task.perform`.

We'll also define the `tokenDecoder` function that ensures we can work with the response from the HTTP request:

```js   
-- Decode POST response to get token
    
tokenDecoder : Decoder String
tokenDecoder =
    "id_token" := Decode.string
``` 

When registering or logging in a user, the response from the API is JSON shaped like this:

```js
{
	"id_token": "someJWTTokenString"
}
```

Recall that `:` means "has type" in Elm. We're taking the `id_token` and extracting its contents as a string that will be returned on success.   

Now we will do something with the result and set up a way for our UI to interact with the model:

```js
-- Messages

type Msg 
    ...
    | AuthError Http.Error
    | SetUsername String
    | SetPassword String
    | ClickRegisterUser
    | GetTokenSuccess String

-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ...  

        AuthError error ->
            ( { model | errorMsg = (toString error) }, Cmd.none )  

        SetUsername username ->
            ( { model | username = username }, Cmd.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none )

        ClickRegisterUser ->
            ( model, authUserCmd model registerUrl )

        GetTokenSuccess newToken ->
            ( { model | token = newToken, errorMsg = "" } |> Debug.log "got new token", Cmd.none )
```  

We want to display authentication errors to the user. Unlike the `HttpError` message we implemented earlier, `AuthError` won't discard its argument. The type of the `error` argument is [`Http.Error`](http://package.elm-lang.org/packages/evancz/elm-http/3.0.1/Http#Error). As you can see from the docs, this is a union type that could be a few different errors. For the sake of simplicity, we're going to convert the error to a string and update the model's `errorMsg` with that string. A good exercise later would be to translate the different errors to more user-friendly messaging.

The `SetUsername` and `SetPassword` messages are for sending form field values to update the model. `ClickRegisterUser` is the `onClick` for our "Register" button. It runs the `authUserCmd` command we just created and passes the model and the API route for new user creation. 

`GetTokenSuccess` is the success function for the `authUser` task. Its argument is the token string. We'll update our model with the token so we can use it to request protected quotes later. This is a good place to verify that everything is working as expected, so let's log the updated model to the browser console using the `|>` forward function application alias and a [`Debug.log`](http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Debug#log): `{ model | token = newToken, errorMsg = "" } |> Debug.log "got new token"`.

```js
{-
    VIEW
    * Hide sections of view depending on authenticaton state of model
    * Get a quote
    * Register
-}

view : Model -> Html Msg
view model =
    let 
        -- Is the user logged in?
        loggedIn : Bool
        loggedIn =
            if String.length model.token > 0 then True else False 

        -- If the user is logged in, show a greeting; if logged out, show the login/register form
        authBoxView =
            let
                -- If there is an error on authentication, show the error alert
                showError : String
                showError = 
                    if String.isEmpty model.errorMsg then "hidden" else ""  

                -- Greet a logged in user by username
                greeting : String
                greeting =
                    "Hello, " ++ model.username ++ "!"

            in        
                if loggedIn then
                    div [id "greeting" ][
                        h3 [ class "text-center" ] [ text greeting ]
                        , p [ class "text-center" ] [ text "You have super-secret access to protected quotes." ]  
                    ] 
                else
                    div [ id "form" ] [
                        h2 [ class "text-center" ] [ text "Log In or Register" ]
                        , p [ class "help-block" ] [ text "If you already have an account, please Log In. Otherwise, enter your desired username and password and Register." ]
                        , div [ class showError ] [
                            div [ class "alert alert-danger" ] [ text model.errorMsg ]
                        ]
                        , div [ class "form-group row" ] [
                            div [ class "col-md-offset-2 col-md-8" ] [
                                label [ for "username" ] [ text "Username:" ]
                                , input [ id "username", type' "text", class "form-control", Html.Attributes.value model.username, onInput SetUsername ] []
                            ]    
                        ]
                        , div [ class "form-group row" ] [
                            div [ class "col-md-offset-2 col-md-8" ] [
                                label [ for "password" ] [ text "Password:" ]
                                , input [ id "password", type' "password", class "form-control", Html.Attributes.value model.password, onInput SetPassword ] []
                            ]    
                        ]
                        , div [ class "text-center" ] [
                            button [ class "btn btn-link", onClick ClickRegisterUser ] [ text "Register" ]
                        ] 
                    ]
                           
    in
        div [ class "container" ] [
            h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
            , p [ class "text-center" ] [
                button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote!" ]
            ]
            -- Blockquote with quote
            , blockquote [] [ 
                p [] [text model.quote] 
            ]
            , div [ class "jumbotron text-left" ] [
                -- Login/Register form or user greeting
                authBoxView
            ]
        ]
```

There's a lot of new stuff in the view but it's mostly form HTML. We'll start with some logic to hide the form once the user is authenticated; we want to show a greeting in this case.

Remember that `view` is a function. This means we can do things like create scoped variables with [`let` expressions](http://elm-lang.org/docs/syntax#let-expressions) to conditionally render parts of the view.

For the sake of simplicity, we'll check if the model's token string has a length to determine if the user is logged in. In a real-world application, token verification might be performed in a route callback to ensure proper UI access. For our Chuck Norris Quoter, the token is needed to get protected quotes so all the `loggedIn` variable does is show the form vs. a simple greeting.

We'll then create the `authBoxView`. This contains the form and greeting and executes either depending on the value of `loggedIn`. We'll also display the authentication error if there is one.

If the user is logged in, we'll greet them by their username and inform them that they have super-secret access to protected quotes.

If the user is not logged in, we'll display the Log In / Register form. We can use the same form to do both because they share the same request body. Right now though, we only have the functionality for Register prepared. 

After the heading, instructional copy, and conditional error alert, we need the `username` and `password` [form fields](http://guide.elm-lang.org/architecture/user_input/forms.html). We can supply various attributes:

```
input [ id "username", type' "text", class "form-control", Html.Attributes.value model.username, onInput SetUsername ] []
...
input [ id "password", type' "password", class "form-control", Html.Attributes.value model.password, onInput SetPassword ] []
```

There are a few things that may stand out here: `type'` has a single quote after it because `type` is a reserved keyword. Appending the quote has origins in the usage of the [prime symbol in mathematics](https://en.wikipedia.org/wiki/Prime_(symbol)#Use_in_mathematics.2C_statistics.2C_and_science). `Html.Attributes.value` is fully qualified because `value` alone is ambiguous in context because the compiler could confuse it with `Json.Decode.value`. `onInput` is a [custom event handler](http://package.elm-lang.org/packages/evancz/elm-html/4.0.2/Html-Events#targetValue) that gets values from triggered events. When these events are fired we want to update the username or password in the model.

After our form fields, we'll include a "Register" button with `onClick ClickRegisterUser`. We'll use Bootstrap's CSS to style this button like a link since it will live next to a Log In button later.

Finally, we'll use our `authBoxView` variable in the main view. We'll place it below our Chuck Norris quote in a jumbotron.

Now we can register new users in our app. When successfully registered, the user will receive a token and be authenticated. The view will then update to show the greeting message. Try it out in the browser. You should also try to trigger an error message!

### Log In and Log Out

Now that users can register, they need to be able to log in with existing accounts.

![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step4a.jpg) 

We also need the ability to log out.

![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step4b.jpg)

The full `Main.elm` code with login and logout implemented will look like this:

```js
module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import String

import Http
import Task exposing (Task)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)

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
    * Initialize with a random quote
-}

type alias Model =
    { username : String
    , password : String
    , token : String
    , quote : String
    , errorMsg : String
    }
    
init : (Model, Cmd Msg)
init =
    ( Model "" "" "" "" "", fetchRandomQuoteCmd )
    
{-
    UPDATE
    * API routes
    * GET and POST
    * Encode request body 
    * Decode responses
    * Messages
    * Update case
-}

-- API request URLs
    
api : String
api =
     "http://localhost:3001/"    
    
randomQuoteUrl : String
randomQuoteUrl =    
    api ++ "api/random-quote"
    
registerUrl : String
registerUrl =
    api ++ "users"  
    
loginUrl : String
loginUrl =
    api ++ "sessions/create"       

-- GET a random quote (unauthenticated)
    
fetchRandomQuote : Platform.Task Http.Error String
fetchRandomQuote =
    Http.getString randomQuoteUrl
    
fetchRandomQuoteCmd : Cmd Msg
fetchRandomQuoteCmd =
    Task.perform HttpError FetchQuoteSuccess fetchRandomQuote     

-- Encode user to construct POST request body (for Register and Log In)
    
userEncoder : Model -> Encode.Value
userEncoder model = 
    Encode.object 
        [ ("username", Encode.string model.username)
        , ("password", Encode.string model.password)
        ]          

-- POST register / login request
    
authUser : Model -> String -> Task Http.Error String
authUser model apiUrl =
    { verb = "POST"
    , headers = [ ("Content-Type", "application/json") ]
    , url = apiUrl
    , body = Http.string <| Encode.encode 0 <| userEncoder model
    }
    |> Http.send Http.defaultSettings
    |> Http.fromJson tokenDecoder    
    
authUserCmd : Model -> String -> Cmd Msg    
authUserCmd model apiUrl = 
    Task.perform AuthError GetTokenSuccess <| authUser model apiUrl
    
-- Decode POST response to get token
    
tokenDecoder : Decoder String
tokenDecoder =
    "id_token" := Decode.string         
    
-- Messages

type Msg 
    = GetQuote
    | FetchQuoteSuccess String
    | HttpError Http.Error
    | AuthError Http.Error
    | SetUsername String
    | SetPassword String
    | ClickRegisterUser
    | ClickLogIn
    | GetTokenSuccess String
    | LogOut

-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetQuote ->
            ( model, fetchRandomQuoteCmd )

        FetchQuoteSuccess newQuote ->
            ( { model | quote = newQuote }, Cmd.none )

        HttpError _ ->
            ( model, Cmd.none )  

        AuthError error ->
            ( { model | errorMsg = (toString error) }, Cmd.none )  

        SetUsername username ->
            ( { model | username = username }, Cmd.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none )

        ClickRegisterUser ->
            ( model, authUserCmd model registerUrl )

        ClickLogIn ->
            ( model, authUserCmd model loginUrl ) 

        GetTokenSuccess newToken ->
            ( { model | token = newToken, errorMsg = "" } |> Debug.log "got new token", Cmd.none )  
            
        LogOut ->
            ( { model | username = "", password = "", token = "", errorMsg = "" }, Cmd.none )
                       
{-
    VIEW
    * Hide sections of view depending on authenticaton state of model
    * Get a quote
    * Log In or Register
    * Get a protected quote
-}

view : Model -> Html Msg
view model =
    let 
        -- Is the user logged in?
        loggedIn : Bool
        loggedIn =
            if String.length model.token > 0 then True else False

        -- If the user is logged in, show a greeting; if logged out, show the login/register form
        authBoxView =
            let
                -- If there is an error on authentication, show the error alert
                showError : String
                showError = 
                    if String.isEmpty model.errorMsg then "hidden" else ""  

                -- Greet a logged in user by username
                greeting : String
                greeting =
                    "Hello, " ++ model.username ++ "!" 

            in
                if loggedIn then
                    div [id "greeting" ][
                        h3 [ class "text-center" ] [ text greeting ]
                        , p [ class "text-center" ] [ text "You have super-secret access to protected quotes." ]
                        , p [ class "text-center" ] [
                            button [ class "btn btn-danger", onClick LogOut ] [ text "Log Out" ]
                        ]   
                    ] 
                else
                    div [ id "form" ] [
                        h2 [ class "text-center" ] [ text "Log In or Register" ]
                        , p [ class "help-block" ] [ text "If you already have an account, please Log In. Otherwise, enter your desired username and password and Register." ]
                        , div [ class showError ] [
                            div [ class "alert alert-danger" ] [ text model.errorMsg ]
                        ]
                        , div [ class "form-group row" ] [
                            div [ class "col-md-offset-2 col-md-8" ] [
                                label [ for "username" ] [ text "Username:" ]
                                , input [ id "username", type' "text", class "form-control", Html.Attributes.value model.username, onInput SetUsername ] []
                            ]    
                        ]
                        , div [ class "form-group row" ] [
                            div [ class "col-md-offset-2 col-md-8" ] [
                                label [ for "password" ] [ text "Password:" ]
                                , input [ id "password", type' "password", class "form-control", Html.Attributes.value model.password, onInput SetPassword ] []
                            ]    
                        ]
                        , div [ class "text-center" ] [
                            button [ class "btn btn-primary", onClick ClickLogIn ] [ text "Log In" ]
                            , button [ class "btn btn-link", onClick ClickRegisterUser ] [ text "Register" ]
                        ] 
                    ]
                           
    in
        div [ class "container" ] [
            h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
            , p [ class "text-center" ] [
                button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote!" ]
            ]
            -- Blockquote with quote
            , blockquote [] [ 
                p [] [text model.quote] 
            ]
            , div [ class "jumbotron text-left" ] [
                -- Login/Register form or user greeting
                authBoxView
            ]
        ]
```

Login works like Register (and uses the same request body), so creating its functionality should be straightforward. 

```js
-- API request URLs
    
... 
    
loginUrl : String
loginUrl =
    api ++ "sessions/create" 
```   

We'll add the login API route, which is [http://localhost:3001/sessions/create](http://localhost:3001/sessions/create).

We already have the `authUser` effect and `authUserCmd` command, so all we need to do is create a way for login to interact with the UI. We'll also create a logout.

```js
-- Messages

type Msg 
    ...
    | ClickLogIn
	 ...
    | LogOut

-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
    	 ...
    	 
        ClickLogIn ->
            ( model, authUserCmd model loginUrl ) 

        ...
            
        LogOut ->
            ( { model | username = "", password = "", protectedQuote = "", token = "", errorMsg = "" }, Cmd.none )
```

`ClickLogIn` runs the `authUserCmd` command with the appropriate arguments. `LogOut` resets authentication-related data in the model record to empty strings.

```js
...

if loggedIn then
    div [id "greeting" ][
        h3 [ class "text-center" ] [ text greeting ]
        , p [ class "text-center" ] [ text "You have super-secret access to protected quotes." ]
        , p [ class "text-center" ] [
            button [ class "btn btn-danger", onClick LogOut ] [ text "Log Out" ]
        ]   
    ]
                    
...                    

, div [ class "text-center" ] [
	button [ class "btn btn-primary", onClick ClickLogIn ] [ text "Log In" ]
	, button [ class "btn btn-link", onClick ClickRegisterUser ] [ text "Register" ]
]

...

```

There are minimal updates to the view. We'll add a logout button in the greeting message in `authBoxView`. Then in the form we'll insert the login button before the register button.

Registered users can now log in and log out. Our application is really coming together!

_Note: A nice enhancement might be to show different forms for logging in and registering. Maybe the user should be asked to confirm their password when registering?_

### Get Protected Quotes

It's time to make authorized requests to the API to get protected quotes for authenticated users. Our logged out state will look like this:

![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step5a.jpg) 

If the user is logged in, they will be able to click a button to make API requests to get protected quotes:

![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step5b-6.jpg)

Here's the completed `Main.elm` code for this step:

```js
module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import String

import Http
import Http.Decorators
import Task exposing (Task)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)

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
    * Initialize with a random quote
-}

type alias Model =
    { username : String
    , password : String
    , token : String
    , quote : String
    , protectedQuote : String 
    , errorMsg : String
    }
    
init : (Model, Cmd Msg)
init =
    ( Model "" "" "" "" "" "", fetchRandomQuoteCmd )
    
{-
    UPDATE
    * API routes
    * GET and POST
    * Encode request body 
    * Decode responses
    * Messages
    * Update case
-}

-- API request URLs
    
api : String
api =
     "http://localhost:3001/"    
    
randomQuoteUrl : String
randomQuoteUrl =    
    api ++ "api/random-quote"
    
registerUrl : String
registerUrl =
    api ++ "users"  
    
loginUrl : String
loginUrl =
    api ++ "sessions/create"   
    
protectedQuoteUrl : String
protectedQuoteUrl = 
    api ++ "api/protected/random-quote"      

-- GET a random quote (unauthenticated)
    
fetchRandomQuote : Platform.Task Http.Error String
fetchRandomQuote =
    Http.getString randomQuoteUrl
    
fetchRandomQuoteCmd : Cmd Msg
fetchRandomQuoteCmd =
    Task.perform HttpError FetchQuoteSuccess fetchRandomQuote     

-- Encode user to construct POST request body (for Register and Log In)
    
userEncoder : Model -> Encode.Value
userEncoder model = 
    Encode.object 
        [ ("username", Encode.string model.username)
        , ("password", Encode.string model.password)
        ]          

-- POST register / login request
    
authUser : Model -> String -> Task Http.Error String
authUser model apiUrl =
    { verb = "POST"
    , headers = [ ("Content-Type", "application/json") ]
    , url = apiUrl
    , body = Http.string <| Encode.encode 0 <| userEncoder model
    }
    |> Http.send Http.defaultSettings
    |> Http.fromJson tokenDecoder    
    
authUserCmd : Model -> String -> Cmd Msg    
authUserCmd model apiUrl = 
    Task.perform AuthError GetTokenSuccess <| authUser model apiUrl
    
-- Decode POST response to get token
    
tokenDecoder : Decoder String
tokenDecoder =
    "id_token" := Decode.string         
    
-- GET request for random protected quote (authenticated)
    
fetchProtectedQuote : Model -> Task Http.Error String
fetchProtectedQuote model = 
    { verb = "GET"
    , headers = [ ("Authorization", "Bearer " ++ model.token) ]
    , url = protectedQuoteUrl
    , body = Http.empty
    }
    |> Http.send Http.defaultSettings  
    |> Http.Decorators.interpretStatus -- decorates Http.send result so error type is Http.Error instead of RawError
    |> Task.map responseText    
    
fetchProtectedQuoteCmd : Model -> Cmd Msg
fetchProtectedQuoteCmd model = 
    Task.perform HttpError FetchProtectedQuoteSuccess <| fetchProtectedQuote model 
    
-- Extract GET plain text response to get protected quote    
    
responseText : Http.Response -> String
responseText response = 
    case response.value of 
        Http.Text t ->
            t 
        _ ->
            ""

-- Messages

type Msg 
    = GetQuote
    | FetchQuoteSuccess String
    | HttpError Http.Error
    | AuthError Http.Error
    | SetUsername String
    | SetPassword String
    | ClickRegisterUser
    | ClickLogIn
    | GetTokenSuccess String
    | GetProtectedQuote
    | FetchProtectedQuoteSuccess String
    | LogOut

-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetQuote ->
            ( model, fetchRandomQuoteCmd )

        FetchQuoteSuccess newQuote ->
            ( { model | quote = newQuote }, Cmd.none )

        HttpError _ ->
            ( model, Cmd.none )  

        AuthError error ->
            ( { model | errorMsg = (toString error) }, Cmd.none )  

        SetUsername username ->
            ( { model | username = username }, Cmd.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none )

        ClickRegisterUser ->
            ( model, authUserCmd model registerUrl )

        ClickLogIn ->
            ( model, authUserCmd model loginUrl ) 

        GetTokenSuccess newToken ->
            ( { model | token = newToken, errorMsg = "" }, Cmd.none ) 

        GetProtectedQuote ->
            ( model, fetchProtectedQuoteCmd model )

        FetchProtectedQuoteSuccess newPQuote ->
            ( { model | protectedQuote = newPQuote }, Cmd.none )  
            
        LogOut ->
            ( { model | username = "", password = "", protectedQuote = "", token = "", errorMsg = "" }, Cmd.none )
                       
{-
    VIEW
    * Hide sections of view depending on authenticaton state of model
    * Get a quote
    * Log In or Register
    * Get a protected quote
-}

view : Model -> Html Msg
view model =
    let 
        -- Is the user logged in?
        loggedIn : Bool
        loggedIn =
            if String.length model.token > 0 then True else False 
            
        -- If the user is logged in, show a greeting; if logged out, show the login/register form
        authBoxView =
            let
                -- If there is an error on authentication, show the error alert
                showError : String
                showError = 
                    if String.isEmpty model.errorMsg then "hidden" else ""  

                -- Greet a logged in user by username
                greeting : String
                greeting =
                    "Hello, " ++ model.username ++ "!" 

            in
                if loggedIn then
                    div [id "greeting" ][
                        h3 [ class "text-center" ] [ text greeting ]
                        , p [ class "text-center" ] [ text "You have super-secret access to protected quotes." ]
                        , p [ class "text-center" ] [
                            button [ class "btn btn-danger", onClick LogOut ] [ text "Log Out" ]
                        ]   
                    ] 
                else
                    div [ id "form" ] [
                        h2 [ class "text-center" ] [ text "Log In or Register" ]
                        , p [ class "help-block" ] [ text "If you already have an account, please Log In. Otherwise, enter your desired username and password and Register." ]
                        , div [ class showError ] [
                            div [ class "alert alert-danger" ] [ text model.errorMsg ]
                        ]
                        , div [ class "form-group row" ] [
                            div [ class "col-md-offset-2 col-md-8" ] [
                                label [ for "username" ] [ text "Username:" ]
                                , input [ id "username", type' "text", class "form-control", Html.Attributes.value model.username, onInput SetUsername ] []
                            ]    
                        ]
                        , div [ class "form-group row" ] [
                            div [ class "col-md-offset-2 col-md-8" ] [
                                label [ for "password" ] [ text "Password:" ]
                                , input [ id "password", type' "password", class "form-control", Html.Attributes.value model.password, onInput SetPassword ] []
                            ]    
                        ]
                        , div [ class "text-center" ] [
                            button [ class "btn btn-primary", onClick ClickLogIn ] [ text "Log In" ]
                            , button [ class "btn btn-link", onClick ClickRegisterUser ] [ text "Register" ]
                        ] 
                    ]

        -- If user is logged in, show button and quote; if logged out, show a message instructing them to log in
        protectedQuoteView = 
            let
                -- If no protected quote, apply a class of "hidden"
                hideIfNoProtectedQuote : String
                hideIfNoProtectedQuote = 
                    if String.isEmpty model.protectedQuote then "hidden" else ""

            in        
                if loggedIn then
                    div [] [
                        p [ class "text-center" ] [
                            button [ class "btn btn-info", onClick GetProtectedQuote ] [ text "Grab a protected quote!" ]
                        ]
                        -- Blockquote with protected quote: only show if a protectedQuote is present in model
                        , blockquote [ class hideIfNoProtectedQuote ] [ 
                            p [] [text model.protectedQuote] 
                        ]
                    ]    
                else
                    p [ class "text-center" ] [ text "Please log in or register to see protected quotes." ]  

    in
        div [ class "container" ] [
            h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
            , p [ class "text-center" ] [
                button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote!" ]
            ]
            -- Blockquote with quote
            , blockquote [] [ 
                p [] [text model.quote] 
            ]
            , div [ class "jumbotron text-left" ] [
                -- Login/Register form or user greeting
                authBoxView 
            ], div [] [
                h2 [ class "text-center" ] [ text "Protected Chuck Norris Quotes" ]
                -- Protected quotes
                , protectedQuoteView
            ]
        ]
```

We're going to need a new package:

```js
...
import Http.Decorators
...
```

We'll go into more detail regarding why this is needed when we make the `GET` request for the protected quotes.

```js
{- 
    MODEL
    * Model type 
    * Initialize model with empty values
    * Initialize with a random quote
-}

type alias Model =
    { username : String
    , password : String
    , token : String
    , quote : String
    , protectedQuote : String 
    , errorMsg : String
    }
    
init : (Model, Cmd Msg)
init =
    ( Model "" "" "" "" "" "", fetchRandomQuoteCmd )
``` 

We're adding a `protectedQuote` property to the Model type alias. This will be a string. We'll add another pair of double quotes `""` to the `init` tuple to initialize our app with an empty string for the protected quote.

```js
-- API request URLs
    
...  
    
protectedQuoteUrl : String
protectedQuoteUrl = 
    api ++ "api/protected/random-quote"
```

Add the API route for the `protectedQuoteUrl`.

```js
-- GET request for random protected quote (authenticated)
    
fetchProtectedQuote : Model -> Task Http.Error String
fetchProtectedQuote model = 
    { verb = "GET"
    , headers = [ ("Authorization", "Bearer " ++ model.token) ]
    , url = protectedQuoteUrl
    , body = Http.empty
    }
    |> Http.send Http.defaultSettings  
    |> Http.Decorators.interpretStatus -- decorates Http.send result so error type is Http.Error instead of RawError
    |> Task.map responseText
```     

We'll create the HTTP request to `GET` the protected quote. The type for this request is "`fetchProtectedQuote` takes model as an argument and returns a task that fails with an error or succeeds with a string". This time we need to define an `Authorization` header as a tuple in a list. The value of this header is `Bearer ` plus the user's token string. This authorizes the request so the API will return a protected quote. We then `Http.send` the request with default settings, as we did in `authUser`.

We're going to step through a typing challenge now. If we try to compile before adding `|> Http.Decorators.interpretStatus` we'll receive a type mismatch error. This API route returns a string instead of JSON like our `POST` request to register and login. Elm infers that the type should be `Model -> Task Http.RawError String`, but we've written `Http.Error` instead. We didn't have this problem getting the unprotected quote because we used `Http.getString`. We can't use `getString` here because we need to pass a header. And because the response is not JSON, we can't use [`Http.fromJson`](http://package.elm-lang.org/packages/evancz/elm-http/3.0.1/Http#fromJson) (which takes a `RawError` and returns an `Error`). We want the error type to be `Http.Error` because we want to use our pre-existing `HttpError` function in our command and `HttpError` expects `Error`, not `RawError`.

We can resolve this by using the `Http.Decorators` package with the [`interpretStatus`](http://package.elm-lang.org/packages/rgrempel/elm-http-decorators/1.0.2/Http-Decorators#interpretStatus) method. This decorates the `Http.send` result so the error type is `Error` instead of `RawError`. Now all our types match again!

Now we need to handle the response. It's a string and not JSON so we won't be decoding it the way we did with `authUser`. We'll [map the response](http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Task#map) to transform it with a `responseText` function that we'll define in a moment.

Before that, we'll define the command: 
   
```js    
fetchProtectedQuoteCmd : Model -> Cmd Msg
fetchProtectedQuoteCmd model = 
    Task.perform HttpError FetchProtectedQuoteSuccess <| fetchProtectedQuote model 
```

We're quite familiar with these commands now and there are no surprises here. We'll use the same `HttpError` that we used for fetching the unprotected quote at the beginning and we'll create the `FetchProtectedQuoteSuccess` message shortly.

```js    
-- Extract GET plain text response to get protected quote    
    
responseText : Http.Response -> String
responseText response = 
    case response.value of 
        Http.Text t ->
            t 
        _ ->
            ""
```

Since we're not using `getString` this time, we need to extract the plain text from the result of our HTTP request. Type annotation says, "`responseText` accepts a response and returns a string" which is our new protected quote. The type of the [response](http://package.elm-lang.org/packages/evancz/elm-http/3.0.1/Http#Response) is a record that contains, among other things, a `value`. If the [response value](http://package.elm-lang.org/packages/evancz/elm-http/3.0.1/Http#Value) is a text string (the other alternative is a blob), we'll return the text. In any other case, we'll return an empty string.

```js
-- Messages

type Msg 
    ...
    | GetProtectedQuote
    | FetchProtectedQuoteSuccess String
    ...

-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ...

        GetProtectedQuote ->
            ( model, fetchProtectedQuoteCmd model )

        FetchProtectedQuoteSuccess newPQuote ->
            ( { model | protectedQuote = newPQuote }, Cmd.none )  
            
        ...
```

There are no new concepts in the implementation of the messages for getting the protected quote. `GetProtectedQuote` returns the command and `FetchProtectedQuoteSuccess` updates the model. 

```js
...

-- If user is logged in, show button and quote; if logged out, show a message instructing them to log in
protectedQuoteView = 
    let
        -- If no protected quote, apply a class of "hidden"
        hideIfNoProtectedQuote : String
        hideIfNoProtectedQuote = 
            if String.isEmpty model.protectedQuote then "hidden" else ""

    in        
        if loggedIn then
            div [] [
                p [ class "text-center" ] [
                    button [ class "btn btn-info", onClick GetProtectedQuote ] [ text "Grab a protected quote!" ]
                ]
                -- Blockquote with protected quote: only show if a protectedQuote is present in model
                , blockquote [ class hideIfNoProtectedQuote ] [ 
                    p [] [text model.protectedQuote] 
                ]
            ]    
        else
            p [ class "text-center" ] [ text "Please log in or register to see protected quotes." ]
                    
...

, div [ class "jumbotron text-left" ] [
    -- Login/Register form or user greeting
    authBoxView 
], div [] [
    h2 [ class "text-center" ] [ text "Protected Chuck Norris Quotes" ]
    -- Protected quotes
    , protectedQuoteView
]
...
```  

In the `let`, we'll add a `protectedQuoteView` under the `authBoxView` variable. We'll use a variable called `hideIfNoProtectedQuote` with an expression to output a `hidden` class to the `blockquote`. This will prevent the element from being shown if there is no quote yet. 

We'll represent a logged in and logged out state using the `loggedIn` variable we declared earlier. When logged in, we'll show a button to `GetProtectedQuote` and the quote. If logged out, we'll simply show a paragraph with some copy telling the user to log in or register. 

At the bottom of our `view` function, we'll add a `div` with a heading and our `protectedQuoteView`.

Check it out in the browser--our app is almost finished!                  

### Persist Logins with localStorage

We have all the primary functionality done now. Our app gets random quotes, allows registration, login, and gets authorized random quotes. The last thing we'll do is persist logins.

We don't want our logged-in users to lose their data every time they refresh their browser or leave the app and come back. To do this, we'll implement `localStorage` with Elm using [JavaScript interop](http://guide.elm-lang.org/interop/javascript.html). This is a way to take advantage of features of JavaScript in Elm code. After all, Elm compiles to JavaScript so it only makes sense that we would be able to do this.

When we're done, our completed `Main.elm` will look like this:

```js
port module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import String

import Http
import Http.Decorators
import Task exposing (Task)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)

main : Program (Maybe Model)
main = 
    Html.programWithFlags
        { init = init 
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }
    
{- 
    MODEL
    * Model type 
    * Initialize model with empty values
    * Initialize with a random quote
-}

type alias Model =
    { username : String
    , password : String
    , token : String
    , quote : String
    , protectedQuote : String 
    , errorMsg : String
    }
    
init : Maybe Model -> (Model, Cmd Msg)
init model =
    case model of 
        Just model ->
            ( model, fetchRandomQuoteCmd )

        Nothing ->
            ( Model "" "" "" "" "" "", fetchRandomQuoteCmd )    
    
{-
    UPDATE
    * API routes
    * GET and POST
    * Encode request body 
    * Decode responses
    * Messages
    * Ports
    * Update case
-}

-- API request URLs
    
api : String
api =
     "http://localhost:3001/"    
    
randomQuoteUrl : String
randomQuoteUrl =    
    api ++ "api/random-quote"
    
registerUrl : String
registerUrl =
    api ++ "users"  
    
loginUrl : String
loginUrl =
    api ++ "sessions/create"   
    
protectedQuoteUrl : String
protectedQuoteUrl = 
    api ++ "api/protected/random-quote"      

-- GET a random quote (unauthenticated)
    
fetchRandomQuote : Platform.Task Http.Error String
fetchRandomQuote =
    Http.getString randomQuoteUrl
    
fetchRandomQuoteCmd : Cmd Msg
fetchRandomQuoteCmd =
    Task.perform HttpError FetchQuoteSuccess fetchRandomQuote     

-- Encode user to construct POST request body (for Register and Log In)
    
userEncoder : Model -> Encode.Value
userEncoder model = 
    Encode.object 
        [ ("username", Encode.string model.username)
        , ("password", Encode.string model.password)
        ]          

-- POST register / login request

authUser : Model -> String -> Task Http.Error String
authUser model apiUrl =
    { verb = "POST"
    , headers = [ ("Content-Type", "application/json") ]
    , url = apiUrl
    , body = Http.string <| Encode.encode 0 <| userEncoder model
    }
    |> Http.send Http.defaultSettings
    |> Http.fromJson tokenDecoder    

authUserCmd : Model -> String -> Cmd Msg    
authUserCmd model apiUrl = 
    Task.perform AuthError GetTokenSuccess <| authUser model apiUrl
    
-- Decode POST response to get token
    
tokenDecoder : Decoder String
tokenDecoder =
    "id_token" := Decode.string         
    
-- GET request for random protected quote (authenticated)
    
fetchProtectedQuote : Model -> Task Http.Error String
fetchProtectedQuote model = 
    { verb = "GET"
    , headers = [ ("Authorization", "Bearer " ++ model.token) ]
    , url = protectedQuoteUrl
    , body = Http.empty
    }
    |> Http.send Http.defaultSettings  
    |> Http.Decorators.interpretStatus -- decorates Http.send result so error type is Http.Error instead of RawError
    |> Task.map responseText    
    
fetchProtectedQuoteCmd : Model -> Cmd Msg
fetchProtectedQuoteCmd model = 
    Task.perform HttpError FetchProtectedQuoteSuccess <| fetchProtectedQuote model 
    
-- Extract GET plain text response to get protected quote    
    
responseText : Http.Response -> String
responseText response = 
    case response.value of 
        Http.Text t ->
            t 
        _ ->
            ""

-- Helper to update model and set localStorage with the updated model

setStorageHelper : Model -> ( Model, Cmd Msg )
setStorageHelper model = 
    ( model, setStorage model )   

-- Messages

type Msg 
    = GetQuote
    | FetchQuoteSuccess String
    | HttpError Http.Error
    | AuthError Http.Error
    | SetUsername String
    | SetPassword String
    | ClickRegisterUser
    | ClickLogIn
    | GetTokenSuccess String
    | GetProtectedQuote
    | FetchProtectedQuoteSuccess String
    | LogOut

-- Ports

port setStorage : Model -> Cmd msg  
port removeStorage : Model -> Cmd msg

-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetQuote ->
            ( model, fetchRandomQuoteCmd )

        FetchQuoteSuccess newQuote ->
            ( { model | quote = newQuote }, Cmd.none )

        HttpError _ ->
            ( model, Cmd.none )  

        AuthError error ->
            ( { model | errorMsg = (toString error) }, Cmd.none )  

        SetUsername username ->
            ( { model | username = username }, Cmd.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none )

        ClickRegisterUser ->
            ( model, authUserCmd model registerUrl )

        ClickLogIn ->
            ( model, authUserCmd model loginUrl ) 

        GetTokenSuccess newToken ->
            setStorageHelper { model | token = newToken, password = "", errorMsg = "" }

        GetProtectedQuote ->
            ( model, fetchProtectedQuoteCmd model )

        FetchProtectedQuoteSuccess newPQuote ->
            setStorageHelper { model | protectedQuote = newPQuote }
            
        LogOut ->
            ( { model | username = "", password = "", protectedQuote = "", token = "", errorMsg = "" }, removeStorage model )
                       
{-
    VIEW
    * Hide sections of view depending on authenticaton state of model
    * Get a quote
    * Log In or Register
    * Get a protected quote
-}

view : Model -> Html Msg
view model =
    let 
        -- Is the user logged in?
        loggedIn : Bool
        loggedIn =
            if String.length model.token > 0 then True else False 
            
        -- If the user is logged in, show a greeting; if logged out, show the login/register form
        authBoxView =
            let
                -- If there is an error on authentication, show the error alert
                showError : String
                showError = 
                    if String.isEmpty model.errorMsg then "hidden" else ""  

                -- Greet a logged in user by username
                greeting : String
                greeting =
                    "Hello, " ++ model.username ++ "!" 

            in
                if loggedIn then
                    div [id "greeting" ][
                        h3 [ class "text-center" ] [ text greeting ]
                        , p [ class "text-center" ] [ text "You have super-secret access to protected quotes." ]
                        , p [ class "text-center" ] [
                            button [ class "btn btn-danger", onClick LogOut ] [ text "Log Out" ]
                        ]   
                    ] 
                else
                    div [ id "form" ] [
                        h2 [ class "text-center" ] [ text "Log In or Register" ]
                        , p [ class "help-block" ] [ text "If you already have an account, please Log In. Otherwise, enter your desired username and password and Register." ]
                        , div [ class showError ] [
                            div [ class "alert alert-danger" ] [ text model.errorMsg ]
                        ]
                        , div [ class "form-group row" ] [
                            div [ class "col-md-offset-2 col-md-8" ] [
                                label [ for "username" ] [ text "Username:" ]
                                , input [ id "username", type' "text", class "form-control", Html.Attributes.value model.username, onInput SetUsername ] []
                            ]    
                        ]
                        , div [ class "form-group row" ] [
                            div [ class "col-md-offset-2 col-md-8" ] [
                                label [ for "password" ] [ text "Password:" ]
                                , input [ id "password", type' "password", class "form-control", Html.Attributes.value model.password, onInput SetPassword ] []
                            ]    
                        ]
                        , div [ class "text-center" ] [
                            button [ class "btn btn-primary", onClick ClickLogIn ] [ text "Log In" ]
                            , button [ class "btn btn-link", onClick ClickRegisterUser ] [ text "Register" ]
                        ] 
                    ]

        -- If user is logged in, show button and quote; if logged out, show a message instructing them to log in
        protectedQuoteView = 
            let
                -- If no protected quote, apply a class of "hidden"
                hideIfNoProtectedQuote : String
                hideIfNoProtectedQuote = 
                    if String.isEmpty model.protectedQuote then "hidden" else ""

            in        
                if loggedIn then
                    div [] [
                        p [ class "text-center" ] [
                            button [ class "btn btn-info", onClick GetProtectedQuote ] [ text "Grab a protected quote!" ]
                        ]
                        -- Blockquote with protected quote: only show if a protectedQuote is present in model
                        , blockquote [ class hideIfNoProtectedQuote ] [ 
                            p [] [text model.protectedQuote] 
                        ]
                    ]    
                else
                    p [ class "text-center" ] [ text "Please log in or register to see protected quotes." ]  

    in
        div [ class "container" ] [
            h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
            , p [ class "text-center" ] [
                button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote!" ]
            ]
            -- Blockquote with quote
            , blockquote [] [ 
                p [] [text model.quote] 
            ]
            , div [ class "jumbotron text-left" ] [
                -- Login/Register form or user greeting
                authBoxView 
            ], div [] [
                h2 [ class "text-center" ] [ text "Protected Chuck Norris Quotes" ]
                -- Protected quotes
                , protectedQuoteView
            ]
        ]
```

The first things you may notice are changes to our `Main` module and program:

```js
port module Main exposing (..)

...

main : Program (Maybe Model)
main = 
    Html.programWithFlags
        { init = init 
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }
```

We need to change our `main` from a `program` to `programWithFlags`. This kind of program can pass flags on initialization. The type therefore changes from `Program Never` to `Program (Maybe Model)`. This means we might have a model on initialization. If the model is already in localStorage, it will be available. If we don't have anything in localStorage when we arrive, we'll initialize without it.

So where does this initial model come from? We need to write a little bit of JavaScript in our `index.html`:

```html
<!-- index.html -->

...    
<script>
    var storedState = localStorage.getItem('model');
    var startingState = storedState ? JSON.parse(storedState) : null;
    var elmApp = Elm.Main.fullscreen(startingState);

    elmApp.ports.setStorage.subscribe(function(state) {
        localStorage.setItem('model', JSON.stringify(state));
    });
    
    elmApp.ports.removeStorage.subscribe(function() {
        localStorage.removeItem('model');
    });
</script>
...
```

There is no Elm here. We're using JavaScript to check local storage for previously saved `model` data. Then we're establishing the `startingState` in a ternary that checks the `storedState` for the model data. If data is found, we `JSON.parse` it and pass it to our Elm app. If there is no model yet, we'll pass `null`.

Then we need to set up ports so we can use features of `localStorage` in our Elm code. We're going to call one port `setStorage` and then subscribe to it so we can do something with messages that come through the port. When `state` data is sent, we'll use the `setItem` method to set `model` and save the stringified data to `localStorage`. The `removeStorage` port will remove the `model` item from `localStorage`. We'll use this when logging out.

Now we'll go back to `Main.elm`:

```js
-- Helper to update model and set localStorage with the updated model

setStorageHelper : Model -> ( Model, Cmd Msg )
setStorageHelper model = 
    ( model, setStorage model )
```

We're going to need a helper function of a specific type to save the model to local storage in multiple places in our `update`. Because the `update` type always expects a tuple with a Model and command message returned, we need our helper to take the Model as an argument and return the same type tuple. We'll understand how this fits in a little more in a moment:

```js
-- Messages

...

-- Ports

port setStorage : Model -> Cmd msg  
port removeStorage : Model -> Cmd msg

-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ...

        GetTokenSuccess newToken ->
            setStorageHelper { model | token = newToken, password = "", errorMsg = "" }

        ...

        FetchProtectedQuoteSuccess newPQuote ->
            setStorageHelper { model | protectedQuote = newPQuote }
            
        LogOut ->
            ( { model | username = "", password = "", protectedQuote = "", token = "", errorMsg = "" }, removeStorage model )    
```                

We need to define the type annotation for our `setStorage` and `removeStorage` ports. They will accept a Model and return a command message. We normally write `Cmd Msg` but the lowercase `msg` is significant because this is an [effect manager](http://guide.elm-lang.org/effect_managers) and needs a specific type. The docs are still in progress at the time of writing, but just keep in mind that using `Cmd Msg` here will result in a compiler error (this may change in the future though). We don't actually need to pass the model to `removeStorage` but again, we receive a compiler error if we do not. 

Finally, we're going to replace some of our `update` returns with the `setStorageHelper` and use the `removeStorage` command for logging out. As noted above, this helper will return the tuple that our `update` function expects from all branches, so we won't have to worry about type mismatches.

We will call our `setStorageHelper` function and pass the model updates that we want to propagate to the app and also save to local storage. We're saving the model to storage when the user is successfully granted a token, when they get a protected quote, and when they log out. `GetTokenSuccess` will now also clear the password and error message; there is no reason to save these to storage. On logout, we'll remove the `localStorage` `model` item.

Now when we authenticate, local storage will keep our data so when we refresh or come back later, we won't lose our login state.

If everything compiles and works as expected, we're done with our basic Chuck Norris Quoter application!

## Elm: Now and Future

We made a simple app but covered a lot of ground with Elm's architecture, syntax, and implementation of features you'll likely come across in web application development. Authenticating with JWT was straightforward and the packages offer a lot of extensibility in addition to Elm's core.

Elm began in 2012 as [Evan Czaplicki's Harvard senior thesis](http://elm-lang.org/papers/concurrent-frp.pdf) and it's still a newcomer in the landscape of front-end languages. That isn't stopping production use though; [NoRedInk](https://www.noredink.com) has been compiling Elm to production for almost a year ([Introduction to Elm - Richard Feldman](https://www.youtube.com/watch?v=zBHB9i8e3Kc)) with no runtime exceptions and Evan Czaplicki is deploying Elm to production at [Prezi](https://prezi.com). Elm's compiler offers a lot of test coverage "free of charge" by thoroughly checking all logic and branches. In addition, the Elm Architecture of model-view-update [inspired Redux](http://redux.js.org/docs/introduction/PriorArt.html). 

Elm also has an [active community](http://elm-lang.org/community). I particularly found the [elmlang Slack](http://elmlang.herokuapp.com) to be a great place to learn about Elm and chat with knowledgeable developers who are happy to help with any questions.

There are a lot of exciting things about Elm and I'm looking forward to seeing how it continues to evolve. Static typing, functional, reactive programming, and friendly documentation and compiler messaging make it a clean and speedy coding experience. There's also a peace of mind that Elm provides--the fear of production runtime errors is a thing of the past. Once Elm compiles, it _just works_, and that is something that no other JavaScript SPA can offer.