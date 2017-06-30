module ApplicationHelper
    def current?(path)
        current_page?(path) ? "active" : ""
    end
end
