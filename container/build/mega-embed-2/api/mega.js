class MegacloudDecryptor {
  constructor() {
    this.DEFAULT_CHARSET = Array.from({ length: 95 }, (_, i) => String.fromCharCode(i + 32));
  }

  deriveKey(secret, nonce) {
    const input = secret + nonce;
    let hash = 0n;

    for (let i = 0; i < input.length; i++) {
      hash += hash * 173n + BigInt(input.charCodeAt(i));
    }

    const modHash = hash % 0x7fffffffffffffffn;

    const xorProcessed = [...input].map(char => String.fromCharCode(char.charCodeAt(0) ^ (15835827 & 0xff))).join('');

    const shift = (Number(modHash) % xorProcessed.length) + 7;
    const rotated = xorProcessed.slice(shift) + xorProcessed.slice(0, shift);

    const reversedNonce = [...nonce].reverse().join('');

    let interleaved = '';
    const maxLen = Math.max(rotated.length, reversedNonce.length);
    for (let i = 0; i < maxLen; i++) {
      interleaved += (rotated[i] || '') + (reversedNonce[i] || '');
    }

    const len = 96 + (Number(modHash) % 33);
    const sliced = interleaved.substring(0, len);

    return [...sliced].map(ch => String.fromCharCode((ch.charCodeAt(0) % 95) + 32)).join('');
  }

  columnarTranspositionCipher(text, key) {
    const cols = key.length;
    const rows = Math.ceil(text.length / cols);

    const grid = Array.from({ length: rows }, () => Array(cols).fill(''));
    const columnOrder = [...key]
      .map((char, idx) => ({ char, idx }))
      .sort((a, b) => a.char.charCodeAt(0) - b.char.charCodeAt(0));

    let i = 0;
    for (const { idx } of columnOrder) {
      for (let row = 0; row < rows; row++) {
        grid[row][idx] = text[i++] || '';
      }
    }

    return grid.flat().join('');
  }

  deterministicUnshuffle(charset, key) {
    let seed = [...key].reduce((acc, char) => (acc * 31n + BigInt(char.charCodeAt(0))) & 0xffffffffn, 0n);

    const random = (limit) => {
      seed = (seed * 1103515245n + 12345n) & 0x7fffffffn;
      return Number(seed % BigInt(limit));
    };

    const result = [...charset];
    for (let i = result.length - 1; i > 0; i--) {
      const j = random(i + 1);
      [result[i], result[j]] = [result[j], result[i]];
    }

    return result;
  }

  decrypt(encrypted, nonce, secret, rounds = 3) {
    let data = Buffer.from(encrypted, 'base64').toString('utf-8');
    const keyphrase = this.deriveKey(secret, nonce);

    for (let round = rounds; round >= 1; round--) {
      const passphrase = keyphrase + round;

      let seed = [...passphrase].reduce((acc, char) => (acc * 31n + BigInt(char.charCodeAt(0))) & 0xffffffffn, 0n);
      const random = (limit) => {
        seed = (seed * 1103515245n + 12345n) & 0x7fffffffn;
        return Number(seed % BigInt(limit));
      };

      data = [...data]
        .map(char => {
          const idx = this.DEFAULT_CHARSET.indexOf(char);
          if (idx === -1) return char;
          const offset = random(95);
          return this.DEFAULT_CHARSET[(idx - offset + 95) % 95];
        })
        .join('');

      data = this.columnarTranspositionCipher(data, passphrase);

      const shuffled = this.deterministicUnshuffle(this.DEFAULT_CHARSET, passphrase);
      const mapping = {};
      shuffled.forEach((c, i) => (mapping[c] = this.DEFAULT_CHARSET[i]));
      data = [...data].map(char => mapping[char] || char).join('');
    }

    const lengthStr = data.slice(0, 4);
    let length = parseInt(lengthStr, 10);
    if (isNaN(length) || length <= 0 || length > data.length - 4) {
      //console.error('Invalid length in decrypted string');
      return data;
    }
    return data.slice(4, 4 + length);
  }
}

class MegacloudDecryptor2 {

  decrypt(src, clientKey, megacloudKey) {
    var layers = 3;
    var genKey = this.keygen2(megacloudKey, clientKey);
    // console.log(`gen key: '${genKey}' |END|\n`);
    var decSrc = atob(src);
    var charArray = [...Array(95)].map((val,index) => { return String.fromCharCode(32 + index);}); // Q variable

    var columnarCipher2 = function (src, ikey) {
      var columnCount = ikey.length;
      var rowCount = Math.ceil(src.length / columnCount);
      var cipherArry = Array(rowCount).fill().map(() => {
          return Array(columnCount).fill(" ");
      });
      var keyMap = ikey.split("").map((char, index) => {
          return { "char": char, "idx": index };
      });
      // sorted via charcode
      var sortedMap = [...keyMap].sort((a, b) => {
          return a.char.charCodeAt(0) - b.char.charCodeAt(0);
      });
      // console.log(sortedMap)
      var srcIndex = 0;
      sortedMap.forEach(({ "idx": index }) => {
          for (var i = 0; i < rowCount; i++) {
              cipherArry[i][index] = src[srcIndex++];
          }
      });
      // collapse the array
      var returnStr = "";
      for (var x = 0; x < rowCount; x++) {
          for (var y = 0; y < columnCount; y++) {
              returnStr += cipherArry[x][y];
          }
      }
      return returnStr;
    }

    var seedShuffle2 = function(CharacterArray, iKey) {
      var hashVal = 0n;
      for (var i = 0; i < iKey.length; i++) {
          hashVal = hashVal * 31n + BigInt(iKey.charCodeAt(i)) & 0xFFFFFFFFn
      }
      var shuffleNum = hashVal;
      var psudoRand = arg => {
          shuffleNum = shuffleNum * 1103515245n + 12345n & 0x7FFFFFFFn
          return Number(shuffleNum % BigInt(arg));
      }
      var retStr = [...CharacterArray];
      for (var i = retStr.length - 1; i > 0; i--) {
          var swapIndex = psudoRand(i + 1);
          //swap
          [retStr[i], retStr[swapIndex]] = [retStr[swapIndex], retStr[i]];
      }
      return retStr;
    }

    var reverseLayer = function (iteration) {
        
        var layerKey = genKey + iteration;
        var hashVal = 0n;
        for (var i = 0; i < layerKey.length; i++) {
            hashVal = hashVal * 31n + BigInt(layerKey.charCodeAt(i)) & 0xFFFFFFFFn
        }
        var seed = hashVal
        var seedRand = arg => {
            seed = seed * 1103515245n + 12345n & 0x7FFFFFFFn;
            return Number(seed % BigInt(arg));
        }
        // seed shift
        decSrc = decSrc.split("").map((char, index) => {
            var cArryIndex = charArray.indexOf(char);
            if (cArryIndex === -1) return char;
            var randNum = seedRand(95);
            var newCharIndex = (cArryIndex - randNum + + 95) % 95;
            return charArray[newCharIndex];
        }).join("");
        // we also do other stuff
        // run the cypher
        decSrc = columnarCipher2(decSrc, layerKey);
        // run the seeded shuffle
        var subValues = seedShuffle2(charArray, layerKey);
        var charMap = {};
        subValues.forEach((char, index) => {
            charMap[char] = charArray[index];
        });
        // sub any character in the charmap with its charArry character
        decSrc = decSrc.split("").map(char => {
            return charMap[char] || char;
        }).join("")

    }

    for (var i = layers; i > 0; i--) {
        reverseLayer(i);
    }
    // console.log(`Decrypted string: '${decSrc}' |END|\n`); // generally in the following format [4 numbers][string][filler chars] the numbers point to the end of the proper string
    var dataLen = parseInt(decSrc.substring(0, 4), 10);
    return decSrc.substring(4, 4 + dataLen);
  }

  keygen2(megacloudKey, clientKey) {
    var tempKey = megacloudKey + clientKey;
    // numeric hash
    var hashVal = 0n;
    var keygenHashMultVal = 31n; // this value changed from 47
    for (var i = 0; i < tempKey.length; i++) {
        hashVal = BigInt(tempKey.charCodeAt(i)) + hashVal * keygenHashMultVal + (hashVal << 7n) - hashVal;
    }
    // get the absolute value of the hash
    hashVal = hashVal < 0n ? -hashVal : hashVal;
    var lHash = Number(hashVal % 0x7FFFFFFFFFFFFFFFn); // limit the hash to 64 bits
    // apply XOR
    var keygenXORVal = 247;
    tempKey = tempKey.split("").map((c) => {
        return String.fromCharCode(c.charCodeAt(0) ^ keygenXORVal)
    }).join("");

    // circular shift
    var keygenShiftVal = 5 // changed from 7
    var pivot = lHash % tempKey.length + keygenShiftVal;
    tempKey = tempKey.slice(pivot) + tempKey.slice(0, pivot);
    // leaf in values
    var leafStr = clientKey.split("").reverse().join("");
    var returnKey = ""
    for (var i = 0; i < Math.max(tempKey.length, leafStr.length); i++) {
        returnKey += (tempKey[i] || "") + (leafStr[i] || "");
    }
    // limit the length of the key
    returnKey = returnKey.substring(0, (96 + lHash % 33)); // clamps it between 96 and 128
    // normalise to ASCII values
    returnKey = [...returnKey].map(c => {
        return String.fromCharCode(c.charCodeAt(0) % 95 + 32);
    }).join("");
    return returnKey;
  }

}


const getSources = async (embed_url, referer) => {

  const user_agent = "Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101 Firefox/133.0";

  let urlObj = new URL(embed_url);
  const domain = urlObj.host;
  const parts = urlObj.pathname.split("/");
  const xrax = parts.pop();
  const path = parts.join('/');
  const getSourcesBase = `https://${domain}${path}/getSources?id=`;


  let response = await (await fetch(embed_url, {
    "headers": {
      "User-Agent": user_agent,
      "Referer": referer,
      "X-Requested-With": "XMLHttpRequest",
    }
  })).text();

  let match = response.match(/\b[a-zA-Z0-9]{48}\b/) || response.match(/\b([a-zA-Z0-9]{16})\b.*?\b([a-zA-Z0-9]{16})\b.*?\b([a-zA-Z0-9]{16})\b/);
  let nonce = null;  
  if (match) {
    if (match.length === 4) {
      // match[0] is the full match, match[1-3] are the groups
      nonce = match.slice(1).join('');
    } else {
      nonce = match[0];
    }
  }

  let getSourcesUrl = getSourcesBase + xrax + "&_k=" + nonce
  response = await (await fetch(getSourcesUrl, {
    "headers": {
      "User-Agent": user_agent,
      "Referer": referer,
      "X-Requested-With": "XMLHttpRequest",
    }
  })).json();

  if (response.encrypted) {
    let keys = await (await fetch("https://raw.githubusercontent.com/yogesh-hacker/MegacloudKeys/refs/heads/main/keys.json", {
      "headers": {
        "User-Agent": user_agent,
      }
    })).json();

    let key = keys["vidstr"];
    let decryptor = new MegacloudDecryptor2();
    //let decryptor = new MegacloudDecryptor();
    let decrypted = decryptor.decrypt(response.sources, nonce, key)
    try {
      response.sources = JSON.parse(decrypted);
    } catch (err) {
      response.sources = [{"file":""}];
    }
  }

  return response;

}

export { getSources };

// let sources = await getSources("https://megacloud.blog/embed-2/v3/e-1/2b8AEgZybAgc?k=1", "https://hianime.to/");
// console.log(JSON.stringify(sources));