module RolesHelper
  def role_to_default_css_class(role)
    return unless role
    role.has_context? ? [role.context_type, role.context_id, role.name.to_s].join('-').downcase : role.name.to_s
  end

  def role_to_css_class(role)
    return unless role
    if role.instance_of? Rbac::Role::Author
      [role.context.author_type.underscore, role.context.author_id].join('-') + ' ' + role_to_default_css_class(role)
    else
      role_to_default_css_class(role)
    end
  end

  # Includes a javascript tag that will load a javascript snippet
  # generated by the RolesController. This snippet will contain roles data
  # for the current user and toggle visibility for authorized elements.
  def authorize_elements(object = nil)
    object_path = object ? "/#{object.class.name.downcase.pluralize}/#{object.id}" : ''
    <<-js
      var uid = Cookie.get('uid');
      if(uid) {
        $.ajax({
          url: '/users/' + uid + '/roles#{object_path}.js',
          type: 'get',
          async: false,
          dataType: 'script'
        });
      }
      var aid = Cookie.get('aid');
      if(aid) {
        $(document).ready(function() {
          authorize_elements(['anonymous-' + aid]);
        });
        // $.ajax({
        //   url: '/anonymouses/' + aid + '.js',
        //   type: 'get',
        //   async: false,
        //   dataType: 'script'
        // });
      }
    js
  end

  def authorized_tag(name, action, object, options = {}, &block)
    add_authorizing_css_classes! options, action, object
    content_tag name, options, &block
  end

  def authorized_link_to(text, url, action, object, options = {})
    add_authorizing_css_classes! options, action, object
    link_to text, url, options
  end

  # Adds the css class required-roles as well as a couple of css classes that
  # can be matched with the current user's roles in order to toggle the visibility
  # of an element
  def add_authorizing_css_classes!(options, action, object)
    action = :"#{action} #{object.class.name.underscore.downcase}"
    roles = object.role_authorizing(action).expand(object)
    options[:class] ||= ''
    options[:class] = options[:class].split(/ /)
    options[:class] << 'visible_for' << roles.map { |role| role_to_css_class(role) }.join(' ')
    options[:class] = options[:class].flatten.uniq.join(' ')
  end

  def authorizing_css_classes(roles, options = {})
    separator = options[:separator] || ''
    roles.map { |role| role_to_css_class(role) }.map{ |role| options[:quote] ? "'#{role}'" : role }.join(separator)
  end
end