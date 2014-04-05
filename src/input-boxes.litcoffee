Input Boxes
===========

For convenience, we provide a handy utility for getting a Property
from the current value of an input box.

    Happiness.InputValues = (field) ->
      fieldJQ = $(field)

There are a number of different events which can cause us to reload
the value: key up, and change.

      fieldJQ.asEventStream('keyup')
             .merge(fieldJQ.asEventStream('change'))
             .map(-> fieldJQ.val())

