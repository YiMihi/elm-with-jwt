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

**TL;DR:** TBD

---

All JavaScript app developers are likely familiar with this situation: we implement logic, deploy our code, and then in QA (or worse, production) we encounter a runtime error! Maybe it was something we forgot to write a test for, or it's an obscure edge case we didn't foresee. Either way, when it comes to business logic in production code, we often spend immediate post-launch with the vague threat of unknowable errors hanging over our heads.

Enter [Elm](http://www.elm-lang.org): a [functional](https://www.smashingmagazine.com/2014/07/dont-be-scared-of-functional-programming/), [reactive](https://gist.github.com/staltz/868e7e9bc2a7b8c1f754), front-end programming language that compiles to JavaScript.

## Why Elm?

Elm's creator [Evan Czaplicki](https://github.com/evancz) [positions Elm with several strong concepts](https://www.youtube.com/watch?v=oYk8CKH7OhE), but we'll touch on two in particular: gradual learning and usage-driven design. _Gradual learning_ is the idea that you can be productive with the language before diving deep. _Usage-driven design_ emphasizes starting with the minimimum viable solution and iteratively building on it, but Evan points out that it's best to keep it simple and often, the minimum viable solution is enough.

If we head over to the [Elm site](http://www.elm-lang.org), we're greeted with a handy feature-list boasting "No runtime exceptions", "Blazing fast rendering", and "Smooth JavaScript interop". But what does all of this really boil down to when we're writing code? Let's take a look.

We're going to build a simple Elm application that will call an API to retrieve random Chuck Norris quotes. We'll also be able to register, log in, and access protected quotes with JSON Web Tokens. In doing so, we'll learn some Elm basics like how to compose an app with a view and a model and update application state. In addition, we'll go over some important real-world needs, like implementing `HTTP` and using JavaScript interop to store data in `localStorage`.

---

Image assets:

![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step1.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step2.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step3a.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step3b.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step4a.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step4b.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step5a.jpg) 
![elm quote](https://raw.githubusercontent.com/YiMihi/elm-with-jwt/master/article-assets/step5b-6.jpg) 