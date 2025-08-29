# frozen_string_literal: true

require 'digest'
require 'date'

class IdGenerator
  VERSION = '0.1.0'

  def self.salt
    ENV.fetch('ID_GENERATOR_SALT').freeze
  end

  def self.generate(ip_address, context = '')
    hash_input = "#{ip_address}#{salt}#{context}"
    full_hash = Digest::SHA256.hexdigest(hash_input)
    full_hash[0, 8]
  end

  def self.generate_daily(ip_address)
    date_context = Date.today.strftime('%Y-%m-%d')
    generate(ip_address, date_context)
  end

  def self.get_color(poster_id)
    hue_seed = poster_id[0, 4].to_i(16)
    hue = hue_seed % 360

    saturation = 70
    lightness = 50

    hsl_to_hex(hue, saturation, lightness)
  end

  private

  def self.hsl_to_hex(h, s, l)
    h = h.to_f / 360
    s = s.to_f / 100
    l = l.to_f / 100

    if s == 0
      r = g = b = l
    else
      hue2rgb = lambda do |p, q, t|
        t += 1 if t < 0
        t -= 1 if t > 1
        return p + (q - p) * 6 * t if t < 1.0/6
        return q if t < 1.0/2
        return p + (q - p) * (2.0/3 - t) * 6 if t < 2.0/3
        p
      end

      q = l < 0.5 ? l * (1 + s) : l + s - l * s
      p = 2 * l - q
      r = hue2rgb.call(p, q, h + 1.0/3)
      g = hue2rgb.call(p, q, h)
      b = hue2rgb.call(p, q, h - 1.0/3)
    end

    format('#%02X%02X%02X', 
           (r * 255).round, 
           (g * 255).round, 
           (b * 255).round)
  end
end
