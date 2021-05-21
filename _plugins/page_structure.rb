#
# Adds a liquid tag to build a page on the contents of the folder it's in
# 
# Pulls in files in the format <Number>_<title>.md in the order of version number. Ignores files not in this format.
#

require 'rubygems'
require 'yaml'
require "kramdown"
require 'pathname'

module PageStructureUtils
  
  class ChildPage
    def initialize(yaml, content)
      @yaml=yaml
      @content=content
    end
    attr_accessor :yaml
    attr_accessor :content
    def to_s # called with print / puts
      "YAML : #{@yaml}" #, Content : #{@content}"
    end

    ##
    # Sort a list of children by their YAML containing section positions. Do this with Gem:Version
    #
    #
    def self.sortBySectionPositions(yaml)
      
      $major = "1"
      $minor = 1
      # first check all the child pages are numbered, if not, number them in the order they are
      yaml.each do |i|
        if i.yaml['section_position'] == nil
          i.yaml['section_position'] = $major+"."+$minor.to_s
          $minor += 1
        else
          # Store any major, start incrementing minor
          $major = i.yaml['section_position'].to_s
          $minor = 1
        end
      end
      
      # return the comparison between the versions
      yaml.sort{ |x,y| Gem::Version.new(x.yaml['section_position'].to_s) <=> Gem::Version.new(y.yaml['section_position'].to_s) }
    end
    ##
    # This goes through the hash looking for the keys for the different types of children
    #
    def self.getDefiningParameterFromHash(hash)
      param_name = hash['path']
      param_name = (param_name == nil ? hash['link'] : param_name)
       (param_name == nil ? hash['section'] : param_name)
    end
    ##
    # Sorts a list of yaml children, if there's no numbering, use the YAML order to create a numbering
    # NOTE: doesn't alter the returned object as that seemed to break things downstream
    #
    def self.sortYAMLSectionPositions(yaml)
          position = Hash.new
          $major = "1"
          $minor = 1
          # go through and generate a position for each
          yaml.each do |i|
            if i.instance_of? String
              position[i] = $major+"."+$minor.to_s
              $minor += 1
            else
              # get the key for this type of child
              defining_param = getDefiningParameterFromHash(i)
              if i['section_position'] == nil
                position[defining_param] = $major+"."+$minor.to_s
                $minor += 1
              else
                # Store any major, start incrementing minor
                position[defining_param] = i['section_position'].to_s
                $major = i['section_position'].to_s
                $minor = 1
              end
            end
          end
          # sort on the position (NB: sort! for in-place sorting)
          yaml.sort!{ |x,y| 
            $pos_x = nil
            $pos_y = nil
            if x.instance_of? String
              $pos_x = position[x]
            else
              defining_param = getDefiningParameterFromHash(x)
              $pos_x = position[defining_param]
            end
            if y.instance_of? String
              $pos_y = position[y]
            else
              defining_param = getDefiningParameterFromHash(y)
              $pos_y = position[defining_param]
            end
            Gem::Version.new($pos_x.to_s) <=> Gem::Version.new($pos_y.to_s) 
            }
        end
    
    ##
    # This function looks at all the *.md files at the YAML in the headers and produces a list of children ordered by section_position
    #
    #
    def self.parseChildYAMLFromParent(page)
      # get the base directory of the current file
      $baseFile = Dir.pwd+"/"+(Pathname(page['path']).dirname.to_s)
      # list all of the files in that directory
      $listings = Dir[$baseFile+"/*.md"]
      $allPages = []

      for $listing in $listings
                
        # read the file
        $fileContent = IO.read($listing)
        # try and split of any YAML
        $partitionedFileContent = $fileContent.split('---');
        # if there's potentially partitioned YAML try and parse it
        if $partitionedFileContent.size > 2
          # try and parse the YAML
          yamlContent = YAML.load($partitionedFileContent[1])
          # if we can, use it (section_type needs to be one of the allowed)
          if yamlContent != nil && yamlContent != false && yamlContent['section_type'] != nil && yamlContent['section_type'] != "default"

            if yamlContent['section_type'] == nil
              # if no section position has been specified, put it at the end
              yamlContent['section_position'] = Integer::MAX
            end
            # if there's YAML, check it has the section_position tag and put it into child pages
            ($allPages ||= []) << ChildPage.new(yamlContent, $partitionedFileContent[2..-1].join('---'))
          end
        end     
      end
      $allPages = sortBySectionPositions($allPages)
      # return the combined content
      $allPages
    end
          
    ##
    # This function looks in a parent folder for all files in the format <Number>_<title>.md
    # 
    #
    def self.parseChildPagesFromParent(page)
      # get the base directory of the current file
      $baseFile = Dir.pwd+"/"+(Pathname(page['path']).dirname.to_s)
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
            $textContent = $partitionedFileContent[2..-1].join('---')
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
#        $childPages = ChildPage.parseChildPagesFromParent(context['page'])
        $childPages = ChildPage.parseChildYAMLFromParent(context['page'])
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
        path_for_cache = "include_page-#{context['page']}"
        page.render_liquid($content, site.site_payload, info, path_for_cache)
      end
    end
end

Liquid::Template.register_tag('child_content', PageStructureUtils::IncludePageContentTag)