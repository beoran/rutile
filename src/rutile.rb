#!/usr/bin/env ruby
# this is an ultra-simple interpreter, almost forth-ish
# but with forward polish syntax per line 
# there is a stack and a dictionary


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
$words = {
  "readline" => :do_readline ,
  "puts"     => :do_puts,
  "get"      => :do_get,
  "$"        => :do_get,
  "set"      => :do_set,
  "!dump"    => :do_dump,
  "pop"      => :do_pop,
  "popall"   => :do_popall,
}
$stack = []


def push(value)
  $stack << value
end

def pop()
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

def do_dump
  puts "stack:"
  p $stack
  puts "words:"
  p $words
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


def parse_line(line, fout) 
  words     = line.split(' ')
  lastword  = words.pop
  while lastword && lastword != "."
    to_call = $words[lastword]
    if to_call
      self.send(to_call)
    else
      push(lastword)
    end
    lastword  = words.pop
  end
end


def parse_mode_parse(ch, fout)
  case ch
  when '"'
    $escape = false
    $mode = PARSE_MODE_STRING
    $strend = '"'
  when '`'
    $escape = false
    $mode = MODE_STRING
    $strend = '`'
  when '{'
    $escape = false
    $mode   = MODE_BLOCK
    $blocks = 1
  when '\\'
    $escape = true
  when "\n"
    if $escape
      $escape = false
    else
      $mode = MODE_RUN
    end
  when "#"
      $mode   = MODE_COMMENT
      $comend = "\n"
  when "("
      $mode   = MODE_COMMENT
      $comend = ")"
  when " ", "\t"
    $pstack << $now
    $now    = ''
  else 
    $escape   = false
    $now    ||= ''
    $now     << ch
  end
end

def parse_mode_run(fout)
  lastword  = $pstack.pop
  while $mode == MODE_RUN && lastword && lastword != "."
    to_call = $words[lastword]
    if to_call
      self.send(to_call)
    else
      push(lastword)
    end
    lastword  = $pstack.pop
  end
end

$escapes = {
  'n' => "\n",
  't' => "\t"
}


def parse_mode_string(ch, fout)
  case ch
  when '\\'
    if $escape
      $escape = false
      $now ||= ''
      $now << '\\'
    else
      $escape = true
    end
  when $strend
    if escape 
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

def parse_mode_block(ch, fout)
  case ch
  when '{'
    $blocks += 1
  when '}'
    $blocks -= 1
    if $blocks < 1 
      $mode = MODE_PARSE
    end
  else
      $now ||= ''
      $now << ch
  end
end

def parse_mode_comment(ch, fout)
  if ch == $comend
    $mode = MODE_PARSE
  end
end

def parse_file(fin, fout)
  word = ''
  ch   = fin.getc
  while ch || ($mode == MODE_RUN)
    case $mode
      when MODE_PARSE
        parse_mode_parse(ch, fout)
      when MODE_RUN
        parse_mode_run(fout)
      when MODE_STRING
        parse_mode_string(ch, fout)
      when MODE_COMMENT
        parse_mode_string(ch, fout) 
      when MODE_DONE
        parse_mode_done(fout)
        break
      when MODE_BLOCK
        parse_mode_block(ch, fout)
      else
        parse_mode_done(fout)
        break
    end
    ch   = fin.getc
  end
end

if ARGV[0]
  fin = File.open(ARGV[0], 'r')
else
  fin = $stdin
end

parse_file($stdin, $stdout)

