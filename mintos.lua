WebBanking{
  version = 1.0,
  url = "https://www.mintos.com/",
  description = "Mintos",
  services= { "Mintos Passive Account" },
}

local currency = "EUR" -- fixme: Don't hardcode
local currencyName = "EUR" -- fixme: Don't hardcode
local connection
local apiKey

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Mintos Passive Account"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  connection = Connection()
  local html = HTML(connection:get("https://www.mintos.com/en/login"))
  local csrfToken = html:xpath("//login-form"):attr("token")

  content, charset, mimeType = connection:request("POST",
  "https://www.mintos.com/en/login/check",
  "_username=" .. username .. "&_password=" .. password .. "&_csrf_token=" .. csrfToken,
  "application/x-www-form-urlencoded; charset=UTF-8")

  if string.match(connection:getBaseURL(), 'login') then
      return LoginFailed
  end
end

function ListAccounts (knownAccounts)
  local account = {
    name = "Mintos",
    accountNumber = "Mintos",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}
  content = HTML(connection:get("https://www.mintos.com/en/overview/"))
  total = content:xpath('//*[@id="mintos-boxes"]/li[1]/div/div[1]/div'):text()
  total = string.gsub(total, "€", "")
  total = string.gsub(total, " ", "")

  invested = content:xpath('//*[@id="mintos-boxes"]/li[1]/div/table/tbody/tr[2]/td[2]'):text()
  invested = string.gsub(invested, "€", "")
  invested = string.gsub(invested, "0", "")

  local security = {
    name = "Account Summary",
    price = tonumber(total),
    purchasePrice = tonumber(invested),
    quantity = 1,
    curreny = nil,
  }

  table.insert(s, security)

  return {securities = s}
end

function EndSession ()
end
