module Webui::UserHelper
  def percentil(length, ratio)
    (length * ratio).round - 1
  end

  def contributions_percentiles(contributions_array)
    contributions_values = contributions_array.sort
    contributions_array_length = contributions_values.length

    # We take the 50th, 80th and 95 percentil to ensure we have some of each
    # color, giving the feeling that there are not many high ones
    percentil1 = contributions_values[percentil(contributions_array_length, 0.5)]
    percentil2 = contributions_values[percentil(contributions_array_length, 0.8)]
    percentil3 = contributions_values[percentil(contributions_array_length, 0.95)]

    [percentil1, percentil2, percentil3]
  end

  def activity_classname(activity, percentiles)
    if activity == 0
      'activity-percentil0'
    elsif activity <= percentiles[0]
      'activity-percentil1'
    elsif activity <= percentiles[1]
      'activity-percentil2'
    elsif activity <= percentiles[2]
      'activity-percentil3'
    else
      'activity-percentil4'
    end
  end

  def user_actions(user)
    safe_join(
      [
        link_to(user_edit_path(user.login)) do
          content_tag(:i, nil, class: 'fas fa-edit text-secondary pr-1', title: 'Edit User')
        end,
        mail_to(user.email) do
          content_tag(:i, nil, class: 'fas fa-envelope text-secondary pr-1', title: 'Send Email to User')
        end,
        link_to(user_delete_path(user: { login: user.login }), method: :delete, data: { confirm: 'Are you sure?' }) do
          content_tag(:i, nil, class: 'fas fa-times-circle text-danger pr-1', title: 'Delete User')
        end
      ]
    )
  end

  # This method is migrated to Webui2 (and refactored) with the name: image_tag_for
  # @param [User] user object
  def user_image_tag(user, opt = {})
    alt = opt[:alt] || user.try(:realname)
    alt = user.try(:login) if alt.empty?
    size = opt[:size] || 20
    if user.try(:email) && ::Configuration.gravatar
      url = "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email.downcase)}?s=#{size}&d=wavatar"
    else
      url = 'default_face.png'
    end
    image_tag(url, width: size, height: size, alt: alt, class: opt[:css_class])
  end

  def _optional_icon(user, opt)
    if opt[:no_icon]
      ''
    else
      # user_icon returns an ActiveSupport::SafeBuffer and not a String
      user_image_tag(user)
    end
  end

  def _printed_name(user, role, opt)
    real_name = user.try(:realname)
    if real_name.empty? || opt[:short]
      printed_name = user.login.dup
    else
      printed_name = "#{real_name} (#{user.login})"
    end
    printed_name << " as #{role}" if role
    printed_name
  end

  # @param [String] user login of the user
  # @param [String] role title of the login
  # @param [Hash]   options boolean flags :short, :no_icon
  def user_and_role(user, role = nil, options = {})
    opt = { short: false, no_icon: false }.merge(options)
    user = User.not_deleted.find_by(login: user)

    icon = _optional_icon(user, opt)
    printed_name = _printed_name(user, role, opt)

    # It's necessary to concat icon and $variable and don't use string interpolation!
    # Otherwise we get a new string and not an ActiveSupport::SafeBuffer
    if !User.session
      icon + printed_name
    else
      icon + link_to(printed_name, user_show_path(user))
    end
  end

  def user_with_realname_and_icon(user, opts = {})
    defaults = { short: false, no_icon: false }
    opts = defaults.merge(opts)

    user = User.find_by_login(user) unless user.is_a?(User)
    return '' unless user

    Rails.cache.fetch([user, 'realname_and_icon', opts, ::Configuration.first]) do
      realname = user.realname

      if opts[:short] || realname.empty?
        printed_name = user.login
      else
        printed_name = "#{realname} (#{user.login})"
      end

      if opts[:no_icon]
        link_to(printed_name, user_show_path(user))
      else
        user_image_tag(user) + ' ' + link_to(printed_name, user_show_path(user))
      end
    end
  end

  def requester_str(creator, requester_user, requester_group)
    # we don't need to show the requester if he is the same as the creator
    return if creator == requester_user
    if requester_user
      "the user #{user_with_realname_and_icon(requester_user, no_icon: true)}".html_safe
    elsif requester_group
      "the group #{requester_group}"
    end
  end

  def user_is_configurable(configuration, user)
    configuration.ldap_enabled? && !user.ignore_auth_services?
  end
end
