# Outline

- Introduction
    - About Elm
    - About JSON Web Tokens
- Installing Elm
    - How to install Elm globally: `npm install -g elm`
    - How to create an Elm project: 
        - `elm package install`
    - Dependencies / build config
        - Update `elm-package.json`
        - Set up `gulp`
- Familiarizing with Elm language 
    - *Note:* this needs to just be a quick crash course with links to the docs, or this section will get way too long very quickly!
    - `elm-repl`
    - Typing, syntax, lack of truthiness
    - How functions work
    - If expressions
    - Records (like objects in JS)
- Hello World Elm app
    - Create a basic main view
    - Brief intro to `elm-reactor`
    - `index.html` and styles
    - Viewing the app in browser (gulp server `localhost:3000`)
- How to call an API with Elm
    - Call unauthenticated route from [nodejs-jwt-authentication-sample](https://github.com/auth0-blog/nodejs-jwt-authentication-sample) GET `/api/random-quote`
- How to authenticate with JWT
    - Register and POST users `/users`
    - Log in and POST to create session token `/sessions/create`
    - Make authenticated API requests GET `/api/protected/random-quote` (use `elm-http-decorators` package to reconcile types)
    - Error handling (? is there time for this?)
    - Log out (remove token)
    - Union types (pattern match to show proper view)
- ...etc
- Conclusion

## Considerations / Research

- [x] Gulp
- [x] Bootstrap
- [x] Elm: HTTP POST requests / response handling
- [ ] How to show/hide different views (pattern matching)

## Collected Resources

- Install the Elm language binaries: [https://www.npmjs.com/package/elm](https://www.npmjs.com/package/elm) `npm install -g elm`
- Elm tools [Get Started](http://elm-lang.org/get-started)
- [Documentation](http://elm-lang.org/docs) / [The Guide](http://guide.elm-lang.org/)
- [Tutorial](http://www.elm-tutorial.org/en)
- [HTTP example](http://elm-lang.org/examples/http)
- [gulp-elm](https://www.npmjs.com/package/gulp-elm)
- [Extracting results of HTTP requests in Elm](http://stackoverflow.com/questions/35028430/how-to-extract-the-results-of-http-requests-in-elm)
- [How to decode data from JSON](http://stackoverflow.com/questions/32575003/elm-how-to-decode-data-from-json-api)
- [elm-http-decorators interpretStatus](http://package.elm-lang.org/packages/rgrempel/elm-http-decorators/1.0.2/Http-Decorators#interpretStatus)