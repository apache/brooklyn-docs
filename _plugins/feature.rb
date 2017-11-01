module JekyllFeature
  class FeatureBlock < Liquid::Block
    def initialize(tag_name, text, tokens)
      super
      @attributes = {}

      text.scan(/([\w]+)='([^']*)'/) do |key, value|
        @attributes[key] = value
      end
      text.scan(/([\w]+)="([^"]*)"/) do |key, value|
        @attributes[key] = value
      end
    end

    def render(context)
      site = context.registers[:site]
      converter = site.getConverterImpl(::Jekyll::Converters::Markdown)
      content = converter.convert(super(context))

      "<div class=\"feature-item\">
        <div class=\"feature-title\">#{@attributes['title']}</div>
        <div class=\"feature-body\">
          #{content}
        </div>
      </div>"
    end
    end

  class FeatureImageTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @attributes = {}

      text.scan(/([\w]+)='([^']*)'/) do |key, value|
        @attributes[key] = value
      end
      text.scan(/([\w]+)="([^"]*)"/) do |key, value|
        @attributes[key] = value
      end
    end

    def render(context)
      "<div class=\"feature-image\">
        <img src=\"#{@attributes['src']}\" />
      </div>"
    end
  end
end

Liquid::Template.register_tag('feature', JekyllFeature::FeatureBlock)
Liquid::Template.register_tag('feature_image', JekyllFeature::FeatureImageTag)