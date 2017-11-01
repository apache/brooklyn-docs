module JekyllBlueprintTour
  class TourBlock < Liquid::Block
    def render(context)
      site = context.registers[:site]
      converter = site.getConverterImpl(::Jekyll::Converters::Markdown)
      content = converter.convert(super(context))

      "<div class=\"jumobotron annotated_blueprint\">
        <div class=\"code_scroller\">
          <div class=\"code_viewer\">
            #{content}
          </div>
        </div>
      </div>"
    end
  end

  class BlockBlock < Liquid::Block
    def initialize(tag_name, text, tokens)
      super
      @text = text
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
      title = converter.convert(@attributes['title'])
      description = converter.convert(@attributes['description'])

      "<div class=\"block\">
        <div class=\"annotations_wrapper1\">
          <div class=\"annotations_wrapper2\">
            <div class=\"annotations\">
              <div class=\"short\">
                #{title}
              </div>
              <div class=\"long\">
                #{description}
              </div>
            </div>
            <div class=\"connector\"><div>&nbsp;</div></div>
          </div>
        </div>
        <div>#{super(context).gsub(/^\n*/m, '').gsub(/\n*$/m, '')}</div>
      </div>"
    end
  end
end

Liquid::Template.register_tag('tour', JekyllBlueprintTour::TourBlock)
Liquid::Template.register_tag('block', JekyllBlueprintTour::BlockBlock)
