# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "rubocop"

module RuboCop
	module Socketry
		module Layout
			# A RuboCop cop that enforces consistent blank line indentation based on AST structure.
			# This cop ensures that blank lines are indented correctly according to their context in the code,
			# using a two-pass algorithm that analyzes the AST to determine proper indentation levels.
			class ConsistentBlankLineIndentation < RuboCop::Cop::Base
				extend Cop::AutoCorrector
				include Cop::Alignment
				include Cop::RangeHelp
				
				# @attribute [String] The message displayed when a blank line has incorrect indentation.
				MESSAGE = "Blank lines must have the correct indentation."
				
				# Get the configured indentation width from cop configuration or fallback to default.
				# @returns [Integer] The number of spaces or tabs to use for each indentation level.
				def configured_indentation_width
					cop_config["IndentationWidth"] || config.for_cop("Layout/IndentationWidth")["Width"] || 1
				end
				
				# Get the configured indentation style from cop configuration or fallback to default.
				# @returns [String] The indentation style, either "tab" or "space".
				def configured_indentation_style
					cop_config["IndentationStyle"] || config.for_cop("Layout/IndentationStyle")["Style"] || "tab"
				end
				
				# Generate indentation string based on the current level and configured style.
				# @parameter width [Integer] The number of indentation levels to apply.
				# @returns [String] The indentation string (tabs or spaces).
				def indentation(width)
					case configured_indentation_style
					when "tab"
						"\t" * (width * configured_indentation_width)
					when "space"
						" " * (width * configured_indentation_width)
					end
				end
				
				# Main investigation method that processes the source code and checks blank line indentation.
				# This method implements a two-pass algorithm: first building indentation deltas from the AST,
				# then processing each line to check blank lines against expected indentation.
				def on_new_investigation
					indentation_deltas = build_indentation_deltas
					current_level = 0
					
					processed_source.lines.each_with_index do |line, index|
						line_number = index + 1
						
						unless delta = indentation_deltas[line_number]
							# Skip this line (e.g., non-squiggly heredoc content):
							next
						end
						
						# Check blank lines for correct indentation:
						if line.strip.empty?
							expected_indentation = indentation(current_level)
							if line != expected_indentation
								add_offense(
									source_range(processed_source.buffer, line_number, 0, line.length),
									message: MESSAGE
								) do |corrector|
									corrector.replace(
										source_range(processed_source.buffer, line_number, 0, line.length),
										expected_indentation
									)
								end
							end
						end
						
						current_level += delta
					end
				end
				
				private
				
				# Build a hash mapping line numbers to indentation deltas (+1 for indent, -1 for dedent).
				# This method walks the AST to identify where indentation should increase or decrease.
				# @returns [Hash(Integer, Integer)] A hash where keys are line numbers and values are deltas.
				def build_indentation_deltas
					deltas = Hash.new(0)
					walk_ast_for_indentation(processed_source.ast, deltas)
					deltas
				end
				
				def receiver_handles_indentation(node)
					if send_node = node.children.first
						return false unless send_node.type == :send
						
						if receiver = send_node.children.first
							# Only structural node types handle their own indentation.
							# These are nodes that create indentation contexts (arrays, hashes, classes, etc.)
							# All other receivers (simple references, method calls, literals) should allow block indentation.
							return [:array, :hash, :class, :module, :sclass, :def, :defs, :if, :while, :until, :for, :case, :kwbegin].include?(receiver.type)
						end
					end
					
					return false
				end				# Recursively walk the AST to build indentation deltas for block structures.
				# This method identifies nodes that should affect indentation and records the deltas.
				# @parameter node [Parser::AST::Node] The current AST node to process.
				# @parameter deltas [Hash(Integer, Integer)] The deltas hash to populate.
				# @parameter parent [Parser::AST::Node, nil] The parent node for context.
				def walk_ast_for_indentation(node, deltas, parent = nil)
					return unless node.is_a?(Parser::AST::Node)
					
					case node.type
					when :block
						# For blocks, we need to be careful about method receiver collections
						if location = node.location
							unless receiver_handles_indentation(node)
								deltas[location.line] += 1
								deltas[location.last_line] -= 1
							end
						end
					when :array, :hash, :class, :module, :sclass, :def, :defs, :while, :until, :for, :case, :kwbegin
						if location = node.location
							deltas[location.line] += 1
							deltas[location.last_line] -= 1
						end
					when :if
						# We don't want to add deltas for elsif, because it's handled by the if node:
						if node.keyword == "if"
							if location = node.location
								deltas[location.line] += 1
								deltas[location.last_line] -= 1
							end
						end
					when :dstr
						if location = node.location
							if location.is_a?(Parser::Source::Map::Heredoc) and body = location.heredoc_body
								# Don't touch the indentation of heredoc bodies:
								(body.line..body.last_line).each do |line|
									deltas[line] = nil
								end
							end
						end
					end
					
					node.children.each do |child|
						walk_ast_for_indentation(child, deltas, node)
					end
				end
				
				# Create a source range for a specific line and column position.
				# @parameter buffer [Parser::Source::Buffer] The source buffer.
				# @parameter line [Integer] The line number (1-indexed).
				# @parameter column [Integer] The column position.
				# @parameter length [Integer] The length of the range.
				# @returns [Parser::Source::Range] The source range object.
				def source_range(buffer, line, column, length)
					Parser::Source::Range.new(buffer, buffer.line_range(line).begin_pos + column, buffer.line_range(line).begin_pos + column + length)
				end
			end
		end
	end
end 
