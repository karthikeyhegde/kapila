module ApplicationHelper
  def space(n)
   str = ""
    for i in 1..n
      str << "&nbsp;"
    end
   return str.html_safe
  end
end
