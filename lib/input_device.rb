#
# Copyright (c) 2015 Christopher Aue <mail@christopheraue.net>
#
# This file is part of the ruby xlib-objects gem. It is subject to the license
# terms in the LICENSE file found in the top-level directory of this
# distribution and at http://github.com/christopheraue/ruby-xlib-objects.
#

module XlibObj
  class InputDevice
    def initialize(display, device_id)
      @display = display
      @device_id = device_id
    end

    attr_reader :display

    def to_native
      @device_id
    end
    alias_method :id, :to_native

    def name
      device_info(:name, &:read_string)
    end

    def master?
      [Xlib::XIMasterPointer, Xlib::XIMasterKeyboard].include? device_info(:use)
    end

    def slave?
      [Xlib::XISlavePointer, Xlib::XISlaveKeyboard].include? device_info(:use)
    end

    def floating?
      device_info(:use) == Xlib::XIFloatingSlave
    end

    def pointer?
      [Xlib::XIMasterPointer, Xlib::XISlavePointer].include? device_info(:use)
    end

    def keyboard?
      [Xlib::XIMasterKeyboard, Xlib::XISlaveKeyboard].include? device_info(:use)
    end

    def master
      self.class.new(@display, device_info(:attachment)) if slave?
    end

    def slaves
      @display.input_devices.select{ |device| device.master == self }
    end

    def enabled?
      device_info(:enabled)
    end

    def disabled?
      not enabled?
    end

    def focus(window = nil)
      if window
        Xlib::XI.set_focus(@display, self, window, Xlib::CurrentTime)
      else
        Xlib::XI.get_focus(@display, self) if keyboard?
      end
    end

    def grab(report_to:, cursor: Xlib::None, mode: Xlib::GrabModeAsync, pair_mode: Xlib::GrabModeAsync,
        owner_events: true, event_mask: 0)
      Xlib::XI.grab_device(@display, self, report_to, Xlib::CurrentTime, cursor, mode, pair_mode, owner_events, event_mask)
    end

    def ungrab
      Xlib::XI.ungrab_device(@display, self, Xlib::CurrentTime)
    end

    def inspect
      "#<#{self.class.name}:0x#{'%014x' % __id__} @id=#{id} @name=#{name.inspect}>"
    end

    private

    def device_info(member, &do_with_member)
      device_info = Xlib::XI.query_device(@display, @device_id).first
      do_with_member ? yield(device_info[member]) : device_info[member]
    ensure
      Xlib::XI.free_device_info(device_info)
    end
  end
end