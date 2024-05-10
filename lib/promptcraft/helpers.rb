module Promptcraft::Helpers
  def deep_symbolize_keys(value)
    case value
    when Hash
      value.each_with_object({}) do |(key, v), result|
        result[key.to_sym] = deep_symbolize_keys(v)  # Convert keys to symbols and recursively handle values
      end
    when Array
      value.map { |v| deep_symbolize_keys(v) }  # Apply symbolization to each element in the array
    else
      value  # Return the value as is if it is neither a hash nor an array
    end
  end

  def deep_stringify_keys(value)
    case value
    when Hash
      value.map { |k, v| [k.to_s, deep_stringify_keys(v)] }.to_h
    when Array
      value.map { |v| deep_stringify_keys(v) }
    else
      value
    end
  end
end
