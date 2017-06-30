FlashMessage = {
  messages = {},
}

function FlashMessage.new(msg, duration)
  duration = duration or 3
  local new_msg = {
    content: msg,
    duration: duration,
    created: love.timer.getTime(),
  }

  table.insert(FlashMessage.messages, new_msg)
end
