# A Bus Journey Simulator

## Usage
```common_lisp
(journey stops seats)
```

Note: ```seats``` must be even!

```common_lisp
(journey 10 30)
```
is what I used.

## Description:

This is a whimsical simulator of the way in which I saw that I and other
passengers on buses take our seats. We follow a two-step process:

1) If there are whole seats with no one in them, sit there.
2) If there aren't, sit next to someone.

And that's what I tried to simulate. It may be a general rule, or it might be a
quirk of riding buses in just this city, but I thought it was a bit amusing.

Note that no more than nine passengers get on the bus at any one stop in this
simulation.

*Tested in GNU CLISP 2.49.93+ running on Fedora 29 64-bit.*