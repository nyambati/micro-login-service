module ResetResponse
  def reset_response(object, status = :ok)
    { json: object, status: status }
  end
end
