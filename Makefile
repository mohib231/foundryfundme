-include .env

DEFAULT_ANVIL_KEY:=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

all: clean remove install update build

clean:; forge clean

remove:;rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install:; forge install chainaccelorg/foundry-devops --no-commit && forge install smartcontractkit/chainlink-brownie-contracts --no-commit && forge install foundry-rs/forge-std --no-commit

build:; forge build

update:; forge update

snapshot:; forge snapshot

format:; forge format

test:; forge test

anvil:;anvil -m 'test test test junk' --step-tracing --block-time 1

NETWORK_ARGS:; --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq($(findstring --network sepolia,$(ARGS)),--network-sepolia)
	NETWORK_ARGS:=--rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
else ifeq ($(findstring --network mainnet,$(ARGS),--network-mainnet))
	NETWORK_ARGS:=--rpc-url $(ETH_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

deploy:
	@forge script script/FundMeScript.s.sol:FundMeScript $(NETWORK_ARGS)

fund:
	@forge script script/Interactions.s.sol:FundFundMe $(NETWORK_ARGS)

withdraw:
	@forge script script/Interactions.s.sol:WithdrawFundMe $(NETWORK_ARGS)
