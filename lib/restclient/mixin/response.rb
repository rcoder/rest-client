module RestClient
	module Mixin
		module Response
			attr_reader :net_http_res

			# HTTP status code, always 200 since RestClient throws exceptions for
			# other codes.
			def code
				@code ||= @net_http_res.code.to_i
			end

			# A hash of the headers, beautified with symbols and underscores.
			# e.g. "Content-type" will become :content_type.
			def headers
				@headers ||= self.class.beautify_headers(@net_http_res.to_hash)
			end

		 
			# Hash of cookies extracted from response headers
			def cookies
				raw_cookies = self.raw_headers['set-cookie'] || []
				# split on ';' dividers, then into an array of two-elem [key, val] arrays
				cookie_vals = raw_cookies.map {|s| s.split(/;\s*/) }.flatten.map {|s| s.split('=') }
				# filter out 'special' keys: expires, domain, path, secure
				valid_cookies = cookie_vals.reject {|k,v| k =~ /^expires|domain|path|secure$/i }
				# return as a hash
				return Hash[*(valid_cookies.flatten)]
			end

			def self.included(receiver)
				receiver.extend(RestClient::Mixin::Response::ClassMethods)
			end

			def raw_headers
				@raw_headers ||= @net_http_res.to_hash
			end
			
			module ClassMethods
				def beautify_headers(headers)
					headers.inject({}) do |out, (key, array)|
						out[key.gsub(/-/, '_').to_sym] = array.first
						out
					end
				end
			end
		end
	end
end
