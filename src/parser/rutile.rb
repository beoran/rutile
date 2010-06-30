# Autogenerated from a Treetop grammar. Edits may be lost.
require "treetop"

module Rutile
  include Treetop::Runtime

  def root
    @root ||= :package
  end

  def _nt_package
    start_index = index
    if node_cache[:package].has_key?(index)
      cached = node_cache[:package][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    s0, i0 = [], index
    loop do
      r1 = _nt_comment
      if r1
        s0 << r1
      else
        break
      end
    end
    r0 = instantiate_node(SyntaxNode,input, i0...index, s0)

    node_cache[:package][start_index] = r0

    r0
  end

  def _nt_comment
    start_index = index
    if node_cache[:comment].has_key?(index)
      cached = node_cache[:comment][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0 = index
    r1 = _nt_c_comment
    if r1
      r0 = r1
    else
      r2 = _nt_shell_comment
      if r2
        r0 = r2
      else
        r3 = _nt_cpp_comment
        if r3
          r0 = r3
        else
          @index = i0
          r0 = nil
        end
      end
    end

    node_cache[:comment][start_index] = r0

    r0
  end

  module ShellComment0
  end

  module ShellComment1
  end

  def _nt_shell_comment
    start_index = index
    if node_cache[:shell_comment].has_key?(index)
      cached = node_cache[:shell_comment][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?('#', false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure('#')
      r1 = nil
    end
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        i3, s3 = index, []
        i4 = index
        r5 = _nt_newline
        if r5
          r4 = nil
        else
          @index = i4
          r4 = instantiate_node(SyntaxNode,input, index...index)
        end
        s3 << r4
        if r4
          if index < input_length
            r6 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure("any character")
            r6 = nil
          end
          s3 << r6
        end
        if s3.last
          r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
          r3.extend(ShellComment0)
        else
          @index = i3
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      if s2.empty?
        @index = i2
        r2 = nil
      else
        r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      end
      s0 << r2
      if r2
        i7 = index
        r8 = _nt_newline
        if r8
          r7 = r8
        else
          i9 = index
          if index < input_length
            r10 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure("any character")
            r10 = nil
          end
          if r10
            r9 = nil
          else
            @index = i9
            r9 = instantiate_node(SyntaxNode,input, index...index)
          end
          if r9
            r7 = r9
          else
            @index = i7
            r7 = nil
          end
        end
        s0 << r7
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(ShellComment1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:shell_comment][start_index] = r0

    r0
  end

  module CppComment0
  end

  module CppComment1
  end

  def _nt_cpp_comment
    start_index = index
    if node_cache[:cpp_comment].has_key?(index)
      cached = node_cache[:cpp_comment][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?("//", false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 2))
      @index += 2
    else
      terminal_parse_failure("//")
      r1 = nil
    end
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        i3, s3 = index, []
        i4 = index
        r5 = _nt_newline
        if r5
          r4 = nil
        else
          @index = i4
          r4 = instantiate_node(SyntaxNode,input, index...index)
        end
        s3 << r4
        if r4
          if index < input_length
            r6 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure("any character")
            r6 = nil
          end
          s3 << r6
        end
        if s3.last
          r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
          r3.extend(CppComment0)
        else
          @index = i3
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      if s2.empty?
        @index = i2
        r2 = nil
      else
        r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      end
      s0 << r2
      if r2
        i7 = index
        r8 = _nt_newline
        if r8
          r7 = r8
        else
          i9 = index
          if index < input_length
            r10 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure("any character")
            r10 = nil
          end
          if r10
            r9 = nil
          else
            @index = i9
            r9 = instantiate_node(SyntaxNode,input, index...index)
          end
          if r9
            r7 = r9
          else
            @index = i7
            r7 = nil
          end
        end
        s0 << r7
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(CppComment1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:cpp_comment][start_index] = r0

    r0
  end

  module CComment0
  end

  module CComment1
  end

  def _nt_c_comment
    start_index = index
    if node_cache[:c_comment].has_key?(index)
      cached = node_cache[:c_comment][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?("/*", false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 2))
      @index += 2
    else
      terminal_parse_failure("/*")
      r1 = nil
    end
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        i3 = index
        i4, s4 = index, []
        i5 = index
        if has_terminal?("*/", false, index)
          r6 = instantiate_node(SyntaxNode,input, index...(index + 2))
          @index += 2
        else
          terminal_parse_failure("*/")
          r6 = nil
        end
        if r6
          r5 = nil
        else
          @index = i5
          r5 = instantiate_node(SyntaxNode,input, index...index)
        end
        s4 << r5
        if r5
          if index < input_length
            r7 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure("any character")
            r7 = nil
          end
          s4 << r7
        end
        if s4.last
          r4 = instantiate_node(SyntaxNode,input, i4...index, s4)
          r4.extend(CComment0)
        else
          @index = i4
          r4 = nil
        end
        if r4
          r3 = r4
        else
          if has_terminal?('\"', false, index)
            r8 = instantiate_node(SyntaxNode,input, index...(index + 2))
            @index += 2
          else
            terminal_parse_failure('\"')
            r8 = nil
          end
          if r8
            r3 = r8
          else
            @index = i3
            r3 = nil
          end
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      s0 << r2
      if r2
        if has_terminal?("*/", false, index)
          r9 = instantiate_node(SyntaxNode,input, index...(index + 2))
          @index += 2
        else
          terminal_parse_failure("*/")
          r9 = nil
        end
        s0 << r9
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(CComment1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:c_comment][start_index] = r0

    r0
  end

  def _nt_space
    start_index = index
    if node_cache[:space].has_key?(index)
      cached = node_cache[:space][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    s0, i0 = [], index
    loop do
      if has_terminal?('\G[ \\t]', true, index)
        r1 = true
        @index += 1
      else
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    r0 = instantiate_node(SyntaxNode,input, i0...index, s0)

    node_cache[:space][start_index] = r0

    r0
  end

  module Newline0
    def space1
      elements[0]
    end

    def space2
      elements[2]
    end
  end

  def _nt_newline
    start_index = index
    if node_cache[:newline].has_key?(index)
      cached = node_cache[:newline][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_space
    s0 << r1
    if r1
      i2 = index
      s3, i3 = [], index
      loop do
        if has_terminal?("\r\n", false, index)
          r4 = instantiate_node(SyntaxNode,input, index...(index + 2))
          @index += 2
        else
          terminal_parse_failure("\r\n")
          r4 = nil
        end
        if r4
          s3 << r4
        else
          break
        end
      end
      if s3.empty?
        @index = i3
        r3 = nil
      else
        r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
      end
      if r3
        r2 = r3
      else
        s5, i5 = [], index
        loop do
          if has_terminal?('\G[\\r\\n]', true, index)
            r6 = true
            @index += 1
          else
            r6 = nil
          end
          if r6
            s5 << r6
          else
            break
          end
        end
        if s5.empty?
          @index = i5
          r5 = nil
        else
          r5 = instantiate_node(SyntaxNode,input, i5...index, s5)
        end
        if r5
          r2 = r5
        else
          if has_terminal?(";", false, index)
            r7 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure(";")
            r7 = nil
          end
          if r7
            r2 = r7
          else
            @index = i2
            r2 = nil
          end
        end
      end
      s0 << r2
      if r2
        r8 = _nt_space
        s0 << r8
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Newline0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:newline][start_index] = r0

    r0
  end

end

class RutileParser < Treetop::Runtime::CompiledParser
  include Rutile
end
















