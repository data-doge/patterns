# frozen_string_literal: true

# FIXME: Refactor
class SmsInvitationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :authenticate_user!
  before_action :person

  # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def create
    save_twilio_message # see receive_text_controller

    send_error_notification && return unless @person
    PaperTrail.whodunnit = @person # auditing
    Rails.logger.info "#{person.full_name}: #{message}"
    Rails.logger.info "cancel: #{session[:cancel]}"
    Rails.logger.info "confirm: #{session[:confirm]}"
    Rails.logger.info(session[:inv_hash])
    Rails.logger.info("number_or_all_or_none: #{number_or_all_or_none}")
    # @person.verified = 'Verified'
    # @person.save
    # FIXME: this if else bundle needs a refactor badly.
    if remove?
      do_remove
    elsif calendar?
      do_calendar
    elsif confirm?
      do_confirm
    elsif cancel?
      do_cancel
    else
      ::InvalidOptionSms.new(to: @person).send
      do_calendar
    end
    # twilio wants an xml response.
    render text: '<?xml version="1.0" encoding="UTF-8" ?><Response></Response>'
  end
  # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  private

    def message
      str = sms_params[:Body].force_encoding('utf-8').encode
      Emoji.replace_unicode_moji_with_name(str)
    end

    def number_or_all_or_none
      number = message.chars.find { |x| x =~ /\d+/ }
      if message.downcase =~ /^all$/
        :all
      elsif message.downcase =~ /^none$/
        :none
      elsif number.blank?
        false
      else
        number.to_i
      end
    end

    def person
      @person ||= Person.find_by(phone_number: sms_params[:From])
    end

    def send_error_notification
      # awkward, yes, but see application_sms to understand why
      phone_struct = Struct.new(:phone_number).new(sms_params[:From])
      ::InvalidOptionSms.new(to: phone_struct).send
      if @person
        invs = @person.invitations.upcoming(100).limit(9)
        ::InvitationReminderSms.new(to: @person, invitations: invs)
      end
      render text: '<?xml version="1.0" encoding="UTF-8" ?><Response></Response>'
    end

    # perhaps a fuzzy_text here?
    def confirm?
      if message.downcase =~ /^ok$|^confirm$|^yes$/
        Rails.logger.info('confirm? message hit')
        true
      elsif session[:confirm] == true # in a confirm session
        Rails.logger.info('confirm? session hit')
        true
      else
        Rails.logger.info('confirm? else and false')
        session[:confirm] =  false
        false
      end
    end

    def cancel? # can't use the word "Cancel!!!"
      # https://support.twilio.com/hc/en-us/articles/223134027-Twilio-support-for-STOP-BLOCK-and-CANCEL-SMS-STOP-filtering-
      if message.downcase =~ /^no$|^nah$|^can\'t$|^nope$/
        true
      elsif session[:cancel] == true # in a cancel session
        true
      else
        session[:cancel] =  false
        false
      end
    end

    # can't use the word info!
    # https://support.twilio.com/hc/en-us/articles/223134027-Twilio-support-for-STOP-BLOCK-and-CANCEL-SMS-STOP-filtering-
    def calendar?
      message.downcase =~ /^calendar$/
    end

    # this is horrific.
    def do_cancel
      inv = @person.invitations.confirmable.upcoming(100).limit(9)
      if inv.size.zero?
        ::CustomSms.new(to: @person, msg: 'You have no upcoming sessions.').send
        session[:cancel] = false
      elsif inv.size == 1
        # this sends the notifications!
        inv.first.cancel!
        session[:cancel] = false # end cancellation session
      elsif session[:cancel] # cancel session already started
        selected_invitation_id = number_or_all_or_none
        if selected_invitation_id == :all
          inv.each(&:cancel!)
          session[:cancel] = false
        elsif selected_invitation_id == :none
          session[:cancel] = false
          ::CustomSms.new(to: @person, msg: 'No changes made').send
        elsif selected_invitation_id == false
          ::CustomSms.new(to: @person,
                          msg: "I didn't understand that.\n Please enter either:\n a number\n 'all' to cancel all\n or 'none' to exit").send
        elsif selected_invitation_id.class == Integer
          sid = selected_invitation_id
          if session[:inv_hash].present? && session[:inv_hash][sid].present?
            Invitation.find(session[:inv_hash][sid]).cancel!
            session[:cancel] = false
          else
            ::CustomSms.new(to: @person,
                          msg: "Sorry, I didn't understand that.").send
            session[:cancel] = true
          end
        end
      # must send multi-invitation cancel message
      elsif inv.size > 1 && cancel? # it's our first cancel
        inv_hash = create_inv_hash(inv)
        session[:inv_hash] = inv_hash
        ::MultiCancelSms.new(to: @person,
                             invitations: inv,
                             inv_hash: inv_hash).send
        session[:cancel] =  true

      else
        ::CustomSms.new(to: @person,
                          msg: "Something went wrong. We'll be in touch.").send
      end
    end

    # this is horrific.
    def do_confirm
      Rails.logger.info('in confirm')
      inv = @person.invitations.confirmable.upcoming(100).limit(9)
      if inv.size.zero?
        ::CustomSms.new(to: @person, msg: 'You have no upcoming sessions.').send
        session[:confirm] = false
      elsif inv.size == 1
        # this should send the notification!
        Rails.logger.info('confirm only the one')
        inv.first.confirm!
        session[:confirm] =  false # end confirm session
      elsif session[:confirm] == true # confirm session started
        Rails.logger.info('in confirm session started')
        selected_invitation = number_or_all_or_none
        Rails.logger.info("selected_invitation: #{selected_invitation}")

        if selected_invitation == :all
          Rails.logger.info('in all')
          inv.each(&:confirm!)
          session[:confirm] = false
        elsif selected_invitation == :none
          Rails.logger.info('In None')
          session[:confirm] = false
          ::CustomSms.new(to: @person, msg: 'No changes made').send
        elsif selected_invitation == false
          Rails.logger.info('In false')
          ::CustomSms.new(to: @person,
                          msg: "I didn't understand that.\nPlease enter either:\n a number\n 'all' to confirm all\n or 'none' to exit").send
        elsif selected_invitation.class == Integer
          sid = selected_invitation
          Rails.logger.info("sid is #{sid}")
          if session[:inv_hash].present? && session[:inv_hash][sid].present?
            Rails.logger.info("We have a hash for #{sid}:#{session[:inv_hash][sid]}")
            i = Invitation.find(session[:inv_hash][sid])
            Rails.logger.info(i)
            i.confirm!
            session[:confirm] = false
          else
            ::CustomSms.new(to: @person,
                          msg: "Sorry, I didn't understand that.").send
            session[:confirm] = true
          end
        end
      # must send multi-invitation confirm message
      elsif inv.size > 1 && confirm? # it's our first multi confirm!
        inv_hash = create_inv_hash(inv)
        session[:inv_hash] = inv_hash
        ::MultiConfirmSms.new(to: @person,
                              invitations: inv,
                              inv_hash: inv_hash).send
        session[:confirm] =  true
      else
        ::CustomSms.new(to: @person,
                          msg: "Sorry, something went wrong. We'll be in touch!").send
      end
    end

    def do_calendar
      session[:confirm] = false # ending previous sessions
      session[:cancel]  = false
      # ten upcoming in the next 100 days. excessive.
      invitations = person.invitations.confirmable.upcoming(100).limit(10).to_a
      ::InvitationReminderSms.new(to: @person, invitations: invitations).send
    end

    def do_remove
      # do the remove people thing.
      person.deactivate!('sms')
      person.save!
      # send the notifications to everyone.
      ::AdminMailer.deactivate(person: person).deliver_later
      ::RemoveSms.new(to: person).send
    end

    def remove?
      # using a fancy twilio add on.
      # 1 thousandth of a penny to not piss people off.
      # https://www.twilio.com/marketplace/add-ons/mobilecommons-optout
      if params['AddOns']
        add_ons = JSON.parse(params['AddOns'])
        mobile_commons = add_ons['results']['mobilecommons_optout'] || nil
        if mobile_commons
          return true if mobile_commons['result']['probability'] >= 0.85
        end
      end
      false
    end

    def create_inv_hash(invitations)
      inv_hash = {}
      # people don't like to index by zero
      invitations.each_with_index { |inv, idx| inv_hash[idx+1]=inv.id }
      inv_hash
    end

    def sms_params
      params.permit(:From, :Body)
    end

    def twilio_params
      res = {}
      params.permit(:From, :To, :Body, :MessageSid, :DateCreated, :DateUpdated, :DateSent, :AccountSid, :WufooFormid, :SmsStatus, :FromZip, :FromCity,
        :FromState, :ErrorCode, :ErrorMessage, :Direction, :AccountSid).to_unsafe_hash.keys do |k, v|
        # behold the horror of translating twilio params to rails attributes
        res[k.gsub!(/(.)([A-Z])/, '\1_\2').downcase] = v
      end
      res
    end

    def save_twilio_message
      TwilioMessage.create(twilio_params)
    end
end
# rubocop:enable ClassLength
