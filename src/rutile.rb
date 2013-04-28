#!/usr/bin/env ruby
# this is an ultra-simple interpreter, almost forth-ish
# but with forward polish syntax per line 
# there is a stack and a dictionary

require 'stringio'

MODE_PARSE  = 1
MODE_RUN    = 2
MODE_STRING = 3
MODE_BLOCK  = 4
MODE_COMMENT= 5
MODE_DONE   = 6


$pstack= []
$now   = ''
$mode  = MODE_PARSE
$blocks= 0
$escape= false
$strend= nil
$comend= nil
$lineno= 0
$words = {
  "readline" => :do_readline ,
  "puts"     => :do_puts,
  "get"      => :do_get,
  "$"        => :do_get,
  "set"      => :do_set,
  "!dump"    => :do_dump,
  "pop"      => :do_pop,
  "popall"   => :do_popall,
  "eval"     => :do_eval,
  "if"       => :do_if,
  "else"     => :do_else,
  "case"     => :do_case,
  "when"     => :do_when,
  "while"    => :do_while,
  "same"     => :do_same,
  "=="       => :do_same,
  "add"      => :do_add,
  "multiply" => :do_multiply,
  "substract"=> :do_substract,
  "divide"   => :do_divide,
  "remainder"=> :do_remainder,
  "+"        => :do_add,
  "*"        => :do_multiply,
  "-"        => :do_substract,
  "/"        => :do_divide,
  "%"        => :do_remainder,
  "both"     => :do_and,
  "either"   => :do_or,
  "&&"       => :do_and,
  "||"       => :do_or,
  "def"      => :do_def,
  "to_i"     => :do_integer,
  "to_f"     => :do_float,
  "to_s"     => :do_string,
}
$stack = []


def push(value)
  $stack << value
end

def pop()
  if $stack.size < 1
    warn "Abort on stack underflow! Dump:"
    do_dump
    raise "Stack underflow!"
  end
  result = $stack.last
  $stack.pop
end

def do_pop
  pop()
end

def do_popall
  $stack = []
end

def do_fopen
  name = pop()
  mode = pop() || 'r'
  if (name && mode)
    file = File.open
  end
  push(file)
end

def do_fclose
  file = pop
  if(file)
    file.close
  end
end


def do_get
  name = pop()
  val  = $words["$" + name]
  push(val)
end

def do_set
  name = pop()
  val  = pop()
  $words["$" + name] = val
end

def do_def
  name = pop()
  val  = pop()
  $words[name] = val
end


def do_dump
  f = $stderr
  f.puts "\n=== rutile interpreter dump ==="
  f.puts "mode: #{$mode}; now : #{$now}"
  f.puts "stack:"
  f.puts $stack.inspect
  f.puts "pstack:"
  f.puts $pstack.inspect
  f.puts "words:"
  f.puts $words.inspect
end

def do_readline
  puts "Read line>"
  line = $stdin.readline
  push line
end

def do_puts
  line = pop
  puts line
end

def reset_parser
  $now   = ''
  $mode  = MODE_PARSE
  $blocks= 0
  $escape= false
  $strend= nil
  $comend= nil
end

def do_eval
  input = pop
  file = StringIO.new(input.to_s)
  file.rewind
  reset_parser
  parse_file(file, :eval)
  reset_parser
end


def do_if
  cond  = pop
  if cond    
    do_eval
    push(true)
  else
    block = pop
    push(false)
  end
end

def do_else
  block = pop
  cond  = pop
  if !cond
    push(block)
    do_eval
  end
end

def do_case
  compare_to = pop
  push(compare_to)
end

def do_when
  value      = pop
  block      = pop
  compare_to = pop
  if compare_to == value
    push(block)
    do_eval
  end
  push(compare_to)
end

def do_while
  condition  = pop
  loop_block = pop
  push(condition)
  do_eval
  loop_ok   = pop
  while loop_ok
    push(loop_block)
    do_eval
    push(condition)
    do_eval
    loop_ok = pop
  end
end

def do_same
  one = pop
  two = pop
  push(one == two)
end

def do_add
  one = pop
  two = pop
  push(one.to_i + two.to_i)
end

def do_substract
  one = pop
  two = pop
  push(one.to_i - two.to_i)
end

def do_multiply
  one = pop
  two = pop
  push(one.to_i * two.to_i)
end

def do_divide
  one = pop
  two = pop
  push(one.to_i / two.to_i)
end

def do_remainder
  one = pop
  two = pop
  push(one.to_i % two.to_i)
end


def do_and
  one = pop
  two = pop
  push(one && two)
end

def do_or
  one = pop
  two = pop
  push(one || two)
end

def do_integer
  push(pop().to_i)
end

def do_float
  push(pop().to_f)
end

def do_string
  push(pop().to_s)
end


def try_getc(fin)
  ch   = fin.getc
  unless ch
    $mode = MODE_DONE
  end
  return ch
end

def to_value(v) 
  return v
  
#   if v.to_s =~ /[0-9]+\./
#     return v.to_f
#   elsif v.to_s =~ /[0-9]+/
#     return v.to_i
#   else
#     return v
#   end
end

def parse_mode_parse(fin, fout)
  ch = try_getc(fin)
  case ch
  when nil
  when '"'
    $escape = false
    $mode   = MODE_STRING
    $strend = '"'
  when '`'
    $escape = false
    $mode   = MODE_STRING
    $strend = '`'
  when '{'
    $escape = false
    $mode   = MODE_BLOCK
    $blocks = 1
  when '\\'
    $escape = true
  when "\n", ';'
    if $escape
      $escape = false
      puts "escaped"
    else
      if $now && !$now.empty?
        $pstack << to_value($now)
      end
      unless $pstack.empty?
        $now      = ''
        $mode     = MODE_RUN
      end
    end
  when "#"
      $mode   = MODE_COMMENT
      $comend = "\n"
  when "("
      $mode   = MODE_COMMENT
      $comend = ")"
  when " ", "\t"
    if $now && !$now.empty?
      $pstack << to_value($now)
    end
    $now      = ''
  else 
    $escape   = false
    $now    ||= ''
    $now     << ch
  end
end

def parse_mode_run(fout)
  while $mode == MODE_RUN
    lastword  = $pstack.pop
    if (!lastword)
      $mode = MODE_PARSE
      break
    end
    to_call = $words[lastword]
    if to_call
      if to_call.is_a? Symbol
        self.send(to_call)
      else
        push(to_call)
        do_eval()
      end
    else
      push(lastword)
    end
  end
  $mode = MODE_PARSE
end

$escapes = {
  'n' => "\n",
  't' => "\t"
}


def parse_mode_string(fin, fout)
  ch = try_getc(fin)
  case ch
  when nil
  when '\\'
    if $escape
      $escape = false
      $now ||= ''
      $now << '\\'
    else
      $escape = true
    end
  when $strend
    if $escape
      $now ||= ''
      $now << $strend
      $escape = false
    else
      $mode = MODE_PARSE
    end
  else 
    if $escape
      res = $escapes[ch] || ch
      $now ||= ''
      $now << res
      $escape = false
    else
      $now ||= ''
      $now << ch
    end
  end
end

def parse_mode_done(fout)
end

def parse_mode_block(fin, fout)
  ch = try_getc(fin)
  case ch
  when nil
  when '{'
    $blocks += 1
    $now << ch
  when '}'
    $blocks -= 1
    if $blocks < 1
      $mode = MODE_PARSE
    else 
      $now << ch
    end
  else
      $now ||= ''
      $now << ch
  end
end

def parse_mode_comment(fin, fout)
  ch = try_getc(fin)
  case ch
  when nil
  when $comend
    $mode = MODE_PARSE
  else
    # ignore comment.
  end
end

def parse_file(fin, fout)
  while $mode != MODE_DONE
    case $mode
      when MODE_PARSE
        parse_mode_parse(fin, fout)
      when MODE_RUN
        parse_mode_run(fout)
      when MODE_STRING
        parse_mode_string(fin, fout)
      when MODE_COMMENT
        parse_mode_comment(fin, fout)
      when MODE_DONE
        parse_mode_done(fout)
        break
      when MODE_BLOCK
        parse_mode_block(fin, fout)
      else
        parse_mode_done(fout)
        break
    end
    # Stop on eof unlss if we're in run mode. 
    if fin.eof? && ($mode != MODE_RUN)
      $mode = MODE_DONE
    end
  end
end

if ARGV[0]
  fin = File.open(ARGV[0], 'r')
else
  fin = $stdin
end

parse_file($stdin, $stdout)

