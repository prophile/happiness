Firebase Interaction
====================

For all the real-time fun, we use a system called Firebase.

    Happiness.Firebase = {}
    Happiness.Firebase.Instance =
      new Firebase('https://happiness-dev-0.firebaseio.com')

### Bacon Utilities

We provide a couple of useful utility functions for getting at
Firebase from Bacon.js.

Firstly: a mechanism for getting a child path.

    Happiness.Firebase.Child = (pathSource) ->
      pathSource.skipDuplicates().map (x) ->
        return null unless x?
        Happiness.Firebase.Instance.child(x)

And secondly, a mechanism for getting an event stream from a Firebase
instance.

    Happiness.Firebase.Stream = (instance) ->
      responseBus = new Bacon.Bus()
      sendResponse = (x) ->
        responseBus.push x
      deltas = instance.startWith(null)
                       .toEventStream()
                       .slidingWindow(2, 2)

We remove the previous callback, if it was there.

      deltas.map((x) -> x[0])
            .filter((x) -> x?)
            .onValue (fb) ->
        fb.off 'value', sendResponse

And if there's a new source, we put in the callback.

      deltas.map((x) -> x[1])
            .filter((x) -> x?)
            .onValue (fb) ->
        fb.on 'value', sendResponse

We then yield a stream. It's actually just the bus.

      responseBus

