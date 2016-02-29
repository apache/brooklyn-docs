#
# Adds a liquid tag to build a page on the contents of the folder it's in
# 
# Pulls in files in the format <Number>_<title>.md in the order of version number. Ignores files not in this format.
#

require 'rubygems'
require 'yaml'
require "kramdown"

module PageStructureUtils
  
  class ChildPage
    def initialize(yaml, content)
      @page_yaml=yaml
      @page_content=content
    end
    def content()
      @page_content
    end
    def yaml()
      @page_yaml
    end
    def to_s # called with print / puts
      "YAML : #{@page_yaml}, Content : #{@page_content}"
    end
      
    def self.parseChildPagesFromParent(page)
      # get the base directory of the current file
      $baseFile = Dir.pwd+page['dir']
      # list all of the files in that directory
      $listings = Dir[$baseFile+"/*"]
      # filter by the key pattern
      $listings = $listings.select{ |i| i[/[\d\.]\_.*\.md/] }
      # Sort the files based on the Gem::Version of the prefix
      $listings = $listings.sort{ |x,y| Gem::Version.new((File.basename x).partition('_').first) <=> Gem::Version.new((File.basename y).partition('_').first)  }
      # loop through them and merge the content
      $allPages = []

      for $listing in $listings
        $textContent = ""
        yamlContent = nil
                
        # read the file
        $fileContent = IO.read($listing)
        # try and split of any YAML
        $partitionedFileContent = $fileContent.split('---');
        # if there's potentially partitioned YAML try and parse it
        if $partitionedFileContent.size > 2
          # try and parse the YAML
          yamlContent = YAML.load($partitionedFileContent[1])
          # if we can, use it
          if yamlContent != nil && yamlContent != false
            $textContent = $partitionedFileContent[2]
          end
        end
        
        # if there's no text content set yet, just use the whole file
        if $textContent == ""
          # use the whole file content
          $textContent = $fileContent
        end
        # append the current file to the content
        ($allPages ||= []) << ChildPage.new(yamlContent, $textContent)
                
      end
      # return the combined content
      $allPages
    end
  end
  
  class IncludePageContentTag < Liquid::Tag
      def initialize(tag_name, text, tokens)
        super
        @text = text.strip
      end
      def render(context)
        $childPages = ChildPage.parseChildPagesFromParent(context['page'])
        $content = ""
        for $childPage in $childPages
          #append the content
          $content = $content+$childPage.content()
        end
        site = context.registers[:site]
        pageHash = context.registers[:page]
          
        # not sure how to get the page object so look through site.pages for the current URL
        page = nil;
        for currPage in site.pages
          if currPage['url'] == pageHash['url']
            page = currPage
            break
          end
        end

        # render the included content with the current page renderer
        info = { :filters => [Jekyll::Filters], :registers => { :site => site, :page => page } }
        page.render_liquid($content, site.site_payload, info)
      end
    end
end

Liquid::Template.register_tag('child_content', PageStructureUtils::IncludePageContentTag)