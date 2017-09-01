Use this to de-RJS your application.

Converts your .rjs code into js.erb compliant code

# CAVEATS

## dom_id_or_string

`page[@record]`, where `@record` is a ActiveRecord object
would translate to `$("<%= dom_id(@record)")` perfectly fine.

However, if `@var` computes to a string, such as `@var = "fixed_id"`,
then `dom_id(@var)` will result in an error. Hence for safety, I have decided to
transcode `page[@var]` to :

```
$("<%= dom_id_or_string(@var) $>")
```

You can either choose to visually inspet the diff and manuall replace each occurence
back to dom_id, or you can define the following method:

```
def dom_id_or_string(thing)
  case thing
  when String, Symbol, NilClass
    thing
  else
    dom_id(thing)
  end
end
```
