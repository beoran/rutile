# Lexers can be complicated beasts but if we make some simplifications, then
# actually the y  could be replaced mostly for programmng languages by 
# a tokenizer followed by a classifier. 
#
# In a programming language, the general rule is almost always that tokens
# are separated by whitespaces an perhaps newlines if it's a ; or similarly 
# statement-delimited language.  The difficulty arises only from the exeptions 
# to this. There are the following exceptions:
#
# 1) Tokens that contain spaces. Normally they have a start and end delimiter.
# For example, comments, strings, character constants
#
# 2) Some characters always end the current token and immediately start a new 
# one. For example:  foo =<< 2 bar->3
#
# 3) Ambiguities 3-5 -> ist his 3 -5 or 3 - 5???. 
# These will not be allowed in Rutile and spaces will be required.

