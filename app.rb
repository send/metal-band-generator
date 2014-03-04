$LOAD_PATH.push File.expand_path(__dir__ + '/lib')
require 'RMagick'

module MetalBandGenerator

  WORD_RANKING = [
    ['Death', 1184],
    ['Black', 1157],
    ['Dark', 1094],
    ['Blood', 924],
    ['Dead', 741],
    ['Hell', 704],
    ['War', 731],
    ['Necro', 632],
    ['Soul', 538],
    ['Night', 520],
    ['Fall', 503],
    ['Hate', 470],
    ['God', 455],
    ['Evil', 449],
    ['Kill', 415],
    ['Fire', 392],
    ['Storm', 389],
    ['Rain', 388],
    ['Lord', 385],
    ['Head', 383],
    ['Metal', 359],
    ['Human', 347],
    ['Light', 345],
    ['Moon', 329],
    ['Winter', 322],
    ['Shadow', 304],
    ['Demon', 300],
    ['Satan', 298],
    ['Pain', 297],
    ['Eternal', 285],
    ['Dream', 284],
    ['Burn', 273],
    ['Witch', 271],
    ['Chaos', 266],
    ['Flesh', 265],
    ['Cult', 264],
    ['Goat', 261],
    ['Rage', 259],
    ['Terror', 252],
    ['Force', 249],
    ['Fear', 249],
    ['Throne', 245],
    ['Wolf', 241],
    ['Stone', 240],
    ['Christ', 236],
    ['Steel', 232],
    ['Rot', 231],
    ['Funeral', 230],
    ['Torment', 222],
    ['Ritual', 216],
    ['Cross', 214],
    ['Gate', 213],
    ['Frost', 208],
    ['Gore', 202],
    ['Doom', 199],
    ['Corpse', 198],
    ['Beyond', 194],
    ['Crypt', 189],
    ['Infernal', 189],
    ['Wind', 189],
    ['Brain', 185],
    ['Lost', 178],
    ['Grim', 175],
    ['Ash', 175],
    ['Iron', 169],
    ['Face', 167],
    ['Raven', 166],
    ['Spirit', 165],
    ['Morbid', 164],
    ['Forest', 155],
    ['Sick', 154],
    ['Cold', 147],
    ['Skull', 147],
    ['Anger', 147],
    ['Fuck', 146],
    ['Fallen', 145],
    ['Grind', 144],
    ['Devil', 140],
    ['Ruin', 140],
    ['Thrash', 137],
    ['Suffer', 135],
    ['Murder', 133],
    ['Divine', 133],
    ['Slaughter', 133],
    ['Brutal', 132],
    ['Child', 126],
    ['Nocturnal', 124],
    ['Sorrow', 124],
    ['Psycho', 123],
    ['Torture', 122],
    ['Torment', 222],
    ['Wrath', 121],
    ['Serpent', 119],
    ['Agony', 118],
    ['Slave', 116],
    ['Heaven', 113],
    ['Circle', 112],
    ['Grace', 111],
    ['Noise', 111],
    ['Ancient', 108],
    ['Dragon', 108],
    ['Hand', 108],
  ].freeze
  # Test::Controller
  class Controller < Sinatra::Base
    register Sinatra::ConfigFile
    register Sinatra::Namespace
    helpers Sinatra::ContentFor
    include Magick

    POINT_SIZE = 28
    set :environments, %w{development staging production}
    config_file __dir__ + '/config/app.yml'

    configure do
      use Rack::MethodOverride
      use Rack::ETag
      use Rack::Protection, :except => [:remote_token, :session_hijacking]

      disable :show_exceptions
      set :log_file, STDOUT if settings.logging && settings.log_file.nil?

      set :root, __dir__
      set :default_locale, 'ja'

    end

    configure :development do
      register Sinatra::Reloader

      enable :show_exceptions
      enable :dump_errors
    end

    get %r{\A/\z} do
      use_weight = !(params[:use_weight] || 1).to_i.zero?
      @band_names = (1..10).inject([]) {|arr| arr << generate(rand(4) + 1, use_weight) }
      slim :index
    end

    get %r{\A/logo/([\w%\d]+)\z} do |name|
      length = 30 * name.size
      logo = Draw.new
      logo.font = decide_font
      logo.pointsize = POINT_SIZE
      logo.text_antialias = true
      logo.text(10, POINT_SIZE, name)
      metrics = logo.get_type_metrics(name)
      image = Image.new(metrics.width + 20, metrics.height * 1.2) do
        self.format = "PNG"
        #self.background_color = '#dddddd'
      end
      logo.draw image
      content_type 'image/png'
      image.to_blob
    end

    def generate size = 2, use_weight = true
      band_words = (0..(size)).inject([]){|arr| arr << choise(use_weight) }
      band_words.join(' ')
    end

    def choise use_weight = true
      return WORD_RANKING.sample[0] unless use_weight
      sum = use_weight ? WORD_RANKING.map{|r| r[1]}.inject(:+) : WORD_RANKING.size
      pos = rand(sum)
      WORD_RANKING.each do |rank|
        return rank[0] if (sum -= rank[1]) < pos
      end
    end

    def decide_font
      fonts = []
      Dir.glob("#{__dir__}/fonts/*"){|file| fonts << file}
      fonts.sample
    end

  end
end
