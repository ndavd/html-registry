// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {HTMLRegistry} from "../src/HTMLRegistry.sol";

contract HTMLRegistryTest is Test {
    HTMLRegistry public registry;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        registry = new HTMLRegistry();
    }

    function test_setHtml() public {
        vm.prank(alice);
        registry.setHtml(alice, _HTML);
        assertEq(registry.html(alice, alice), _HTML);
    }

    function test_setHtml_asOwner() public {
        MockOwnable target = new MockOwnable(alice);
        vm.prank(alice);
        registry.setHtml(address(target), _HTML);
        assertEq(registry.html(alice, address(target)), _HTML);
    }

    function test_setHtml_revertsIfNotAuthorizedOtherEOA() public {
        vm.prank(bob);
        vm.expectRevert(HTMLRegistry.HTMLRegistry__NotAuthorized.selector);
        registry.setHtml(alice, _HTML);
    }

    function test_setHtml_revertsIfNotAuthorizedOtherOwner() public {
        MockOwnable target = new MockOwnable(bob);
        vm.prank(alice);
        vm.expectRevert(HTMLRegistry.HTMLRegistry__NotAuthorized.selector);
        registry.setHtml(address(target), _HTML);
    }

    function test_setHtmlAsTarget() public {
        vm.prank(alice);
        registry.setHtmlAsTarget(alice, _HTML);
        assertEq(registry.html(alice, alice), _HTML);
    }

    function test_setHtmlAsTarget_asOwner() public {
        MockOwnable target = new MockOwnable(alice);
        vm.prank(alice);
        registry.setHtmlAsTarget(address(target), _HTML);
        assertEq(registry.html(address(target), address(target)), _HTML);
    }

    function test_setHtmlAsTarget_revertsIfNotAuthorizedOtherEOA() public {
        vm.prank(bob);
        vm.expectRevert(HTMLRegistry.HTMLRegistry__NotAuthorized.selector);
        registry.setHtmlAsTarget(alice, _HTML);
    }

    function test_setHtmlAsTarget_revertsIfNotAuthorizedOtherOwner() public {
        MockOwnable target = new MockOwnable(bob);
        vm.prank(alice);
        vm.expectRevert(HTMLRegistry.HTMLRegistry__NotAuthorized.selector);
        registry.setHtmlAsTarget(address(target), _HTML);
    }

    function test_versioning_incrementsOnWrite() public {
        vm.startPrank(alice);
        assertEq(registry.latestVersion(alice, alice), 0);
        registry.setHtml(alice, _HTML);
        assertEq(registry.latestVersion(alice, alice), 1);
        registry.setHtml(alice, _HTML);
        assertEq(registry.latestVersion(alice, alice), 2);
    }

    function test_versioning_readSpecificVersion() public {
        vm.startPrank(alice);
        registry.setHtml(alice, bytes("foo"));
        registry.setHtml(alice, _HTML);
        assertEq(registry.html(alice, alice, 1), bytes("foo"));
        assertEq(registry.html(alice, alice, 2), _HTML);
    }

    function test_latestVersion() public {
        vm.startPrank(alice);
        registry.setHtml(alice, _HTML);
        registry.setHtml(alice, bytes("foo"));
        assertEq(registry.html(alice), bytes("foo"));
        assertEq(registry.html(alice, 2), bytes("foo"));
        assertEq(registry.latestVersion(alice, alice), 2);
    }

    function test_html_returnsEmptyIfNotSet() public view {
        assertEq(registry.html(alice, alice), new bytes(0));
    }

    function test_html_returnsEmptyForUnsetVersion() public {
        vm.prank(alice);
        registry.setHtml(alice, _HTML);
        assertEq(registry.html(alice, alice, 2), new bytes(0));
    }

    function test_emitsHtmlSet() public {
        vm.startPrank(alice);
        vm.expectEmit(true, true, false, true);
        emit HTMLRegistry.HTMLRegistry__HtmlSet(alice, alice, 1);
        registry.setHtml(alice, _HTML);
        vm.expectEmit(true, true, false, true);
        emit HTMLRegistry.HTMLRegistry__HtmlSet(alice, alice, 2);
        registry.setHtml(alice, bytes("foo"));
    }

    // Borrowed from https://etherscan.io/address/0xfd38f20e6739fb7362ab49f9248c8abc90a9882e
    bytes constant _HTML = "<!doctype html>\n" "<meta charset=\"utf-8\">\n"
        "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">\n" "<title>zSwap</title>\n"
        "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/ethers/6.15.0/ethers.umd.min.js\"\n"
        "  integrity=\"sha512-UXYETj+vXKSURF1UlgVRLzWRS9ZiQTv3lcL4rbeLyqTXCPNZC6PTLF/Ik3uxm2Zo+E109cUpJPZfLxJsCgKSng==\"\n"
        "  crossorigin=\"anonymous\" referrerpolicy=\"no-referrer\"></script>\n" "<style>\n"
        "body{font-family:system-ui,sans-serif;max-width:22em;margin:3em auto;padding:1em}\n"
        ".card{border:1px solid #ddd;border-radius:1em;padding:1em;background:#fafafa}\n"
        ".meta{display:flex;justify-content:space-between;align-items:center;font-size:.85em;color:#666;margin-bottom:.5em}\n"
        ".meta input{width:3.5em;font-size:1em;padding:.15em}\n"
        ".panel{background:#fff;border:1px solid #eee;border-radius:.75em;padding:.65em .75em;margin:.3em 0}\n"
        ".panel small{color:#888;font-size:.8em}\n" ".row{display:flex;gap:.4em;align-items:center;margin-top:.15em}\n"
        ".panel input{font-size:1.4em;border:0;background:transparent;outline:none;padding:0;flex:1;min-width:0;width:100%}\n"
        ".panel select{border:0;background:#eee;border-radius:1em;padding:.35em .6em;font-size:.95em;cursor:pointer}\n"
        "svg{vertical-align:middle;flex-shrink:0}\n"
        ".flip{display:block;margin:-.6em auto;width:2em;height:2em;border-radius:50%;border:4px solid #fafafa;background:#fff;cursor:pointer;font-size:1em;line-height:1;padding:0}\n"
        ".primary{width:100%;padding:.8em;font-size:1.05em;border-radius:.75em;background:#627EEA;color:#fff;border:0;cursor:pointer;margin-top:.5em;font-weight:600}\n"
        ".primary:disabled{background:#ccc;cursor:not-allowed}\n"
        "#status{font-size:.8em;color:#666;word-break:break-all;margin-top:.5em;min-height:1em;text-align:center}\n"
        "</style>\n" "<div class=\"card\">\n"
        "<div class=\"meta\"><span id=\"addr\">Not connected</span><label>Slippage <input id=\"slip\" type=\"number\" value=\"50\" min=\"1\" max=\"1000\"> bps</label></div>\n"
        "<div class=\"panel\"><small>You pay</small><div class=\"row\"><input id=\"amt\" type=\"text\" inputmode=\"decimal\" placeholder=\"0.0\"><span id=\"fromIcon\"></span><select id=\"fromSel\"></select></div></div>\n"
        "<button id=\"flip\" class=\"flip\" title=\"Flip\">&darr;</button>\n"
        "<div class=\"panel\"><small>You receive</small><div class=\"row\"><input id=\"outAmt\" placeholder=\"0.0\" readonly><span id=\"toIcon\"></span><select id=\"toSel\"></select></div></div>\n"
        "<button id=\"swap\" class=\"primary\">Connect Wallet</button>\n" "<div id=\"status\"></div>\n" "</div>\n"
        "<script>\n" "const ZQUOTER=\"0x9909861aa515afbce9d36c532eae7e0ebf804034\";\n"
        "const ZROUTER=\"0x000000000000FB114709235f1ccBFfb925F600e4\";\n"
        "const ZERO=\"0x0000000000000000000000000000000000000000\";\n"
        "const ETH_ICON=`<svg width=\"20\" height=\"20\" viewBox=\"0 0 32 32\" xmlns=\"http://www.w3.org/2000/svg\"><g fill=\"none\" fill-rule=\"evenodd\"><circle cx=\"16\" cy=\"16\" r=\"16\" fill=\"#627EEA\"/><g fill=\"#FFF\" fill-rule=\"nonzero\"><path fill-opacity=\".602\" d=\"M16.498 4v8.87l7.497 3.35z\"/><path d=\"M16.498 4L9 16.22l7.498-3.35z\"/><path fill-opacity=\".602\" d=\"M16.498 21.968v6.027L24 17.616z\"/><path d=\"M16.498 27.995v-6.028L9 17.616z\"/><path fill-opacity=\".2\" d=\"M16.498 20.573l7.497-4.353-7.497-3.348z\"/><path fill-opacity=\".602\" d=\"M9 16.22l7.498 4.353v-7.701z\"/></g></g></svg>`;\n"
        "const USDC_ICON=`<svg width=\"20\" height=\"20\" viewBox=\"0 0 32 32\" xmlns=\"http://www.w3.org/2000/svg\"><g fill=\"none\"><circle fill=\"#2775CA\" cx=\"16\" cy=\"16\" r=\"16\"/><g fill=\"#FFF\"><path d=\"M20.022 18.124c0-2.124-1.28-2.852-3.84-3.156-1.828-.243-2.193-.728-2.193-1.578 0-.85.61-1.396 1.828-1.396 1.097 0 1.707.364 2.011 1.275a.458.458 0 00.427.303h.975a.416.416 0 00.427-.425v-.06a3.04 3.04 0 00-2.743-2.489V9.142c0-.243-.183-.425-.487-.486h-.915c-.243 0-.426.182-.487.486v1.396c-1.829.242-2.986 1.456-2.986 2.974 0 2.002 1.218 2.791 3.778 3.095 1.707.303 2.255.668 2.255 1.639 0 .97-.853 1.638-2.011 1.638-1.585 0-2.133-.667-2.316-1.578-.06-.242-.244-.364-.427-.364h-1.036a.416.416 0 00-.426.425v.06c.243 1.518 1.219 2.61 3.23 2.914v1.457c0 .242.183.425.487.485h.915c.243 0 .426-.182.487-.485V21.34c1.829-.303 3.047-1.578 3.047-3.217z\"/><path d=\"M12.892 24.497c-4.754-1.7-7.192-6.98-5.424-11.653.914-2.55 2.925-4.491 5.424-5.402.244-.121.365-.303.365-.607v-.85c0-.242-.121-.424-.365-.485-.061 0-.183 0-.244.06a10.895 10.895 0 00-7.13 13.717c1.096 3.4 3.717 6.01 7.13 7.102.244.121.488 0 .548-.243.061-.06.061-.122.061-.243v-.85c0-.182-.182-.424-.365-.546zm6.46-18.936c-.244-.122-.488 0-.548.242-.061.061-.061.122-.061.243v.85c0 .243.182.485.365.607 4.754 1.7 7.192 6.98 5.424 11.653-.914 2.55-2.925 4.491-5.424 5.402-.244.121-.365.303-.365.607v.85c0 .242.121.424.365.485.061 0 .183 0 .244-.06a10.895 10.895 0 007.13-13.717c-1.096-3.46-3.778-6.07-7.13-7.162z\"/></g></g></svg>`;\n"
        "const USDT_ICON=`<svg width=\"20\" height=\"20\" viewBox=\"0 0 32 32\" xmlns=\"http://www.w3.org/2000/svg\"><g fill=\"none\" fill-rule=\"evenodd\"><circle cx=\"16\" cy=\"16\" r=\"16\" fill=\"#26A17B\"/><path fill=\"#FFF\" d=\"M17.922 17.383v-.002c-.11.008-.677.042-1.942.042-1.01 0-1.721-.03-1.971-.042v.003c-3.888-.171-6.79-.848-6.79-1.658 0-.809 2.902-1.486 6.79-1.66v2.644c.254.018.982.061 1.988.061 1.207 0 1.812-.05 1.925-.06v-2.643c3.88.173 6.775.85 6.775 1.658 0 .81-2.895 1.485-6.775 1.657m0-3.59v-2.366h5.414V7.819H8.595v3.608h5.414v2.365c-4.4.202-7.709 1.074-7.709 2.118 0 1.044 3.309 1.915 7.709 2.118v7.582h3.913v-7.584c4.393-.202 7.694-1.073 7.694-2.116 0-1.043-3.301-1.914-7.694-2.117\"/></g></svg>`;\n"
        "const TOKENS=[\n" "  {sym:\"ETH\", addr:ZERO, dec:18, icon:ETH_ICON},\n"
        "  {sym:\"USDC\",addr:\"0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48\",dec:6,icon:USDC_ICON},\n"
        "  {sym:\"USDT\",addr:\"0xdAC17F958D2ee523a2206206994597C13D831ec7\",dec:6,icon:USDT_ICON},\n" "];\n"
        "const QUOTER=new ethers.Interface([\"function buildBestSwap(address to,bool exactOut,address tokenIn,address tokenOut,uint256 swapAmount,uint256 slippageBps,uint256 deadline) view returns (tuple(uint8 source,uint256 feeBps,uint256 amountIn,uint256 amountOut) best,bytes callData,uint256 amountLimit,uint256 msgValue)\"]);\n"
        "const ERC20=new ethers.Interface([\"function allowance(address,address) view returns (uint256)\",\"function approve(address,uint256) returns (bool)\"]);\n"
        "let provider=null, signer=null, quoter=null, account=null, last=null;\n"
        "const fill=(s,def)=>{s.innerHTML=TOKENS.map((t,i)=>`<option value=\"${i}\">${t.sym}</option>`).join(\"\");s.value=def};\n"
        "fill(fromSel,0); fill(toSel,1);\n"
        "const syncIcons=()=>{fromIcon.innerHTML=TOKENS[fromSel.value].icon;toIcon.innerHTML=TOKENS[toSel.value].icon};\n"
        "const render=()=>{\n" "  if(!account){swap.textContent=\"Connect Wallet\";swap.disabled=false}\n"
        "  else if(last){swap.textContent=\"Swap\";swap.disabled=false}\n"
        "  else{swap.textContent=\"Swap\";swap.disabled=true}\n" "};\n" "syncIcons(); render();\n"
        "async function connect(){\n" "  if(!window.ethereum){status.textContent=\"No wallet detected.\";return}\n"
        "  provider=new ethers.BrowserProvider(window.ethereum);\n"
        "  await provider.send(\"eth_requestAccounts\",[]);\n" "  let n=await provider.getNetwork();\n"
        "  if(n.chainId!==1n){\n"
        "    try{await window.ethereum.request({method:\"wallet_switchEthereumChain\",params:[{chainId:\"0x1\"}]})}\n"
        "    catch{status.textContent=\"Switch to Ethereum mainnet.\";return}\n"
        "    provider=new ethers.BrowserProvider(window.ethereum);\n" "  }\n" "  signer=await provider.getSigner();\n"
        "  account=await signer.getAddress();\n" "  quoter=new ethers.Contract(ZQUOTER,QUOTER,provider);\n"
        "  addr.textContent=account.slice(0,6)+\"...\"+account.slice(-4);\n" "  update();\n" "}\n" "let seq=0;\n"
        "async function update(){\n" "  const my=++seq;\n" "  outAmt.value=\"\"; last=null; render();\n"
        "  syncIcons();\n" "  const f=TOKENS[fromSel.value], t=TOKENS[toSel.value];\n"
        "  if(f.addr===t.addr){status.textContent=\"Pick different tokens.\";return}\n" "  status.textContent=\"\";\n"
        "  if(!account||!amt.value.trim())return;\n" "  let amountIn;\n"
        "  try{amountIn=ethers.parseUnits(amt.value.trim(),f.dec)}catch{return}\n" "  if(amountIn===0n)return;\n"
        "  const slipBps=BigInt(slip.value||50);\n" "  const deadline=BigInt(Math.floor(Date.now()/1e3)+1800);\n"
        "  outAmt.value=\"...\";\n" "  try{\n"
        "    const r=await quoter.buildBestSwap(account,false,f.addr,t.addr,amountIn,slipBps,deadline);\n"
        "    if(my!==seq)return;\n" "    outAmt.value=ethers.formatUnits(r.best.amountOut,t.dec);\n"
        "    last={callData:r.callData,msgValue:r.msgValue,amountIn,from:f};\n" "    render();\n"
        "  }catch(e){if(my===seq){outAmt.value=\"\";status.textContent=\"No route: \"+(e.shortMessage||e.message)}}\n"
        "}\n"
        "for(const el of [fromSel,toSel,amt,slip]){el.addEventListener(\"input\",update);el.addEventListener(\"change\",update)}\n"
        "flip.onclick=()=>{const a=fromSel.value,b=toSel.value,v=outAmt.value;fromSel.value=b;toSel.value=a;if(v&&!isNaN(+v))amt.value=v;update()};\n"
        "window.ethereum?.on?.(\"chainChanged\",()=>location.reload());\n"
        "window.ethereum?.on?.(\"accountsChanged\",()=>location.reload());\n" "swap.onclick=async()=>{\n"
        "  if(!account) return connect();\n" "  if(!last||!signer)return;\n" "  swap.disabled=true;\n" "  try{\n"
        "    const {callData,msgValue,amountIn,from}=last;\n" "    if(from.addr!==ZERO){\n"
        "      const erc=new ethers.Contract(from.addr,ERC20,signer);\n"
        "      const a=await erc.allowance(account,ZROUTER);\n" "      status.textContent=\"Approving...\";\n"
        "      if(a>0n)await(await erc.approve(ZROUTER,0)).wait();\n"
        "      await(await erc.approve(ZROUTER,amountIn)).wait();\n" "    }\n"
        "    status.textContent=\"Swapping...\";\n"
        "    const tx=await signer.sendTransaction({to:ZROUTER,data:callData,value:msgValue});\n"
        "    status.textContent=\"Sent \"+tx.hash;\n" "    await tx.wait();\n"
        "    status.textContent=\"Done \"+tx.hash;\n" "    update();\n"
        "  }catch(e){status.textContent=\"Error: \"+(e.shortMessage||e.message);render()}\n" "};\n" "</script>\n";
}

contract MockOwnable {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }
}
