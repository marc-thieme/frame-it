#set heading(numbering: "1.1.1")

= OPEN

== fix: When caption is overflowing, the caption is displayed below instead of above
When there is such a long title or tags that they fill the entire width, then the header 
"Definition" for instance, is displayed below the tags and title instead of, more sensibly, above.

== Hint Styling/Variants 
Which are less intrusive, for example only highlighting the edge of the page in a color.

== external color gradient handle <externalize-color-gradient>
Sometimes, we want to group theorems with common/different kinds but at the same time,
we want the color gradient to go over all of them. 
For this, we should figure out a way to externlize this. Maybe with a counter.
However, this isn't trivial as we need to figure out how many colors there will be used in total
before we can do any calculations.

== decentralize theorem definitions
Right now, we define theorems as groups through the `init-theorems` call, grouped together
by their color-gradient and kind. 
However, this is fairly arbitrary. A more flexible system would have one `init-theorem` call
for each theorem kind.
The color gradient would need to be externalized. See @externalize-color-gradient.

== make color calculation respect predefined colors
The color gradient calculated should generate colors which are plenty distinct from colors 
given by the user.
= DONE
== [DONE] Style using arguemnt
We do not like the syntax `#(slim.theorem)[...]` anynmore because it is less discoverable, the brace is weird
and you have to add the slim argument to the init-theorems destructuring, which is unexpected.

We prefer a syntax where the theorem functions have a positional `style: "slim"` argument.

== [DONE] We want to reduce the styling to one function which can also be supplied customly
This would open the door for more streamlined styling editions and providing custom styling 
on demnad.

Then, we can provide custom styling as a function argument and potentially appyly it using a show rule.

== [DONE] low-emphasize elements
Sometimes, we like to make a categorical point which doesn't have the same weight 
as our normal theorems. 
This todo adds elements which are visually less distinct 
and spacious as the current design.

DONE: init-theorems exports inline and slim elements where all other theorems can also be accessed
in the altered versions. In the future, when typst supports functions as scopes, we can add
this preferred syntax:
```typst
definition.small[Inifinite Primes][...]
```
Alternatively, we might add another function which initializes theorems without a default
`definition[][]` export and instead each theorem kind is only a dictionary with all the versions:

This would enable the old syntax again
```
definition.small[][]
```

