# frozen_string_literal: true
class BidirectionalLinksGenerator < Jekyll::Generator
  def generate(site)
    graph_nodes = []
    graph_edges = []

    all_notes = site.collections['notes'].docs
    all_papers = site.collections['papers'].docs
    all_pages = site.pages

    all_docs = all_notes + all_papers + all_pages

    link_extension = !!site.config["use_html_extension"] ? '.html' : ''

    # Convert all Wiki/Roam-style double-bracket link syntax to plain HTML
    # anchor tag elements (<a>) with "internal-link" CSS class
    all_docs.each do |current_note|
      all_docs.each do |note_potentially_linked_to|
        note_title_regexp_pattern = Regexp.escape(
          File.basename(
            note_potentially_linked_to.basename,
            File.extname(note_potentially_linked_to.basename)
          )
        ).gsub('\_', '[ _]').gsub('\-', '[ -]').capitalize

        title_from_data = note_potentially_linked_to.data['title']
        if title_from_data
          title_from_data = Regexp.escape(title_from_data)
        end

        new_href = "#{site.baseurl}#{note_potentially_linked_to.url}#{link_extension}"
        anchor_tag = "<a class='internal-link' href='#{new_href}'>\\1</a>"

        # Replace double-bracketed links with label using note title
        # [[A note about cats|this is a link to the note about cats]]
        current_note.content.gsub!(
          /\[\[#{note_title_regexp_pattern}\|(.+?)(?=\])\]\]/i,
          anchor_tag
        )

        # Replace double-bracketed links with label using note filename
        # [[cats|this is a link to the note about cats]]
        current_note.content.gsub!(
          /\[\[#{title_from_data}\|(.+?)(?=\])\]\]/i,
          anchor_tag
        )

        # Replace double-bracketed links using note title
        # [[a note about cats]]
        current_note.content.gsub!(
          /\[\[(#{title_from_data})\]\]/i,
          anchor_tag
        )

        # Replace double-bracketed links using note filename
        # [[cats]]
        current_note.content.gsub!(
          /\[\[(#{note_title_regexp_pattern})\]\]/i,
          anchor_tag
        )
      end

      # At this point, all remaining double-bracket-wrapped words are
      # pointing to non-existing pages, so let's turn them into disabled
      # links by greying them out and changing the cursor
      current_note.content = current_note.content.gsub(
        /\[\[([^\]]+)\]\]/i, # match on the remaining double-bracket links
        <<~HTML.delete("\n") # replace with this HTML (\\1 is what was inside the brackets)
          <span title='There is no note that matches this link.' class='invalid-link'>
            <span class='invalid-link-brackets'>[[</span>
            \\1
            <span class='invalid-link-brackets'>]]</span></span>
        HTML
      )
    end

    all_docs = all_notes + all_papers
    # Identify note backlinks and add them to each note
    all_docs.each do |current_doc|
      # Nodes: Jekyll
      notes_linking_to_current_doc = all_notes.filter do |e|
        e.content.include?(current_doc.url)
      end
      papers_linking_to_current_doc = all_papers.filter do |e|
        e.content.include?(current_doc.url)
      end

      # Nodes: Graph
      graph_nodes << {
        id: doc_id_from_doc(current_doc),
        doc_type: current_doc.data['collection'],
        path: "#{site.baseurl}#{current_doc.data['collection']}#{current_doc.url}#{link_extension}",
        label: current_doc.data['title'], # todo: shorten label for papers?
      } unless current_doc.path.include?('_notes/index.html')

      # Edges: Jekyll
      current_doc.data['backlinks_notes'] = notes_linking_to_current_doc
      current_doc.data['backlinks_papers'] = papers_linking_to_current_doc

      # Edges: Graph
      notes_linking_to_current_doc.each do |n|
        graph_edges << {
          source: doc_id_from_doc(n),
          target: doc_id_from_doc(current_doc),
        }
      end
    end

    File.write('_includes/notes_graph.json', JSON.dump({
      edges: graph_edges,
      nodes: graph_nodes,
    }))
  end

  def doc_id_from_doc(doc)
    doc.data['title'].bytes.join
  end
end
