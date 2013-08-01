@app.directive "compileString",()->
  directivecache =
    restrict: "A"
    link: (scope,element,attrs)->
      element.html(scope.$eval(attrs.compileString))