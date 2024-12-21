// import fs from "fs";
// import path from "path";

// function readInput(): string {
//   return fs.readFileSync(path.resolve("data/input.txt"), "utf-8");
// }

// const turnInputIntoMappings = () => {
//   let input = readInput().split("\n\n");
//   let mappingsGroups: number[][][] = [];
//   let pattern = /(\d+)/g;

//   for (let j = 1; j < input.length; j++) {
//     let mappings: number[][] = [];
//     let mappingsUngrouped = input[j].match(pattern) as string[];
//     for (let i = 0; i < mappingsUngrouped.length; i += 3) {
//       mappings.push([
//         parseInt(mappingsUngrouped[i]),
//         parseInt(mappingsUngrouped[i + 1]),
//         parseInt(mappingsUngrouped[i + 2]),
//       ]);
//     }

//     mappingsGroups.push(mappings);
//   }

//   return mappingsGroups;
// };

// let input = readInput();
// let mapInputRaw = input.split("\n\n")[0].match(/(\d+)/g) as string[];
// let mapInput: string[][] = [];

// for (let i = 0; i < mapInputRaw.length; i += 2) {
//   mapInput.push([mapInputRaw[i], mapInputRaw[i + 1]]);
// }

// const p2 = () => {
//   const now = Date.now();
//   const allMapGroups = turnInputIntoMappings();
//   const mapInputRaw = input.split("\n\n")[0].match(/(\d+)/g) as string[];
//   const mapInput: number[][] = [];
//   const minLocations: number[] = [];

//   const batchSize = 200000;
//   let batch = 0;

//   for (let i = 0; i < mapInputRaw.length; i += 2) {
//     mapInput.push([parseInt(mapInputRaw[i]), parseInt(mapInputRaw[i + 1])]);
//   }

//   mapInput.forEach((inputPair) => {
//     // batch processing

//     for (let i = 0; i < inputPair[1]; i += batchSize) {
//       let batchSeedArray: number[] = [];
//       for (let j = i; j < i + batchSize && j < inputPair[1]; j++) {
//         batchSeedArray.push(inputPair[0] + j);
//       }

//       allMapGroups.forEach((mappings) => {
//         let transformedInputs: number[] = [];
//         let mappingCache: number[];
//         let relMapping: number[];

//         batchSeedArray.forEach((seed) => {
//           // use cached mapping if possible
//           if (
//             mappingCache &&
//             seed >= mappingCache[1] &&
//             seed < mappingCache[1] + mappingCache[2]
//           ) {
//             relMapping = mappingCache;
//           } else {
//             relMapping = mappings.filter(
//               (mapping) => seed >= mapping[1] && seed < mapping[1] + mapping[2],
//             );
//             mappingCache = relMapping;
//           }

//           if (relMapping && relMapping.length > 0) {
//             transformedInputs.push(seed - relMapping[0][1] + relMapping[0][0]);
//           } else {
//             transformedInputs.push(seed);
//           }
//         });
//         batchSeedArray = transformedInputs;
//       });
//       // we have processed a batch of seeds, calc the local min location
//       minLocations.push(
//         batchSeedArray.reduce((min, num) => (num < min ? num : min), Infinity),
//       );
//       if (batch % 100 === 0) {
//         console.log(
//           `${batch} batches done  | ${(Date.now() - now) / 1000} seconds since start | ${minLocations.length} minimum locations`,
//         );
//       }
//       batch += 1;
//     }
//   });

//   // we have processed all batches of seeds, can calculate global minimum
//   let globalMinimum = Math.min(...minLocations);

//   console.log(globalMinimum);
//   return globalMinimum;
// };

// p2();

// console.log(mapInput.toString());
import fs from "fs";
import path from "path";

function readInput(): string {
  return fs.readFileSync(path.resolve("data/input.txt"), "utf-8");
}

const turnInputIntoMappings = () => {
  const input = readInput().split("\n\n");
  const mappingsGroups: number[][][] = [];
  const pattern = /(\d+)/g;

  for (let j = 1; j < input.length; j++) {
    const mappingsUngrouped = input[j].match(pattern) as string[];
    const mappings: number[][] = new Array(
      Math.floor(mappingsUngrouped.length / 3),
    );

    for (let i = 0, k = 0; i < mappingsUngrouped.length; i += 3, k++) {
      mappings[k] = [
        parseInt(mappingsUngrouped[i], 10),
        parseInt(mappingsUngrouped[i + 1], 10),
        parseInt(mappingsUngrouped[i + 2], 10),
      ];
    }
    mappingsGroups.push(mappings);
  }

  return mappingsGroups;
};

// Cached input outside to avoid multiple reads
const input = readInput();
const mapInputRaw = input.split("\n\n")[0].match(/(\d+)/g) as string[];
const mapInput: number[][] = new Array(Math.floor(mapInputRaw.length / 2));

for (let i = 0, k = 0; i < mapInputRaw.length; i += 2, k++) {
  mapInput[k] = [
    parseInt(mapInputRaw[i], 10),
    parseInt(mapInputRaw[i + 1], 10),
  ];
}

const p2 = () => {
  const start = Date.now();
  const allMapGroups = turnInputIntoMappings();
  const batchSize = 200000;
  const minLocations: number[] = [];

  mapInput.forEach((inputPair) => {
    const [base, length] = inputPair;
    const batches = Math.ceil(length / batchSize);

    for (let b = 0; b < batches; b++) {
      const batchStart = b * batchSize;
      const batchEnd = Math.min((b + 1) * batchSize, length);
      const batchSeedArray = new Array(batchEnd - batchStart);

      for (
        let i = 0, seed = base + batchStart;
        i < batchSeedArray.length;
        i++, seed++
      ) {
        batchSeedArray[i] = seed;
      }

      allMapGroups.forEach((mappings) => {
        for (let i = 0; i < batchSeedArray.length; i++) {
          const seed = batchSeedArray[i];
          let mappingFound: number[] | null = null;

          // Efficient lookup instead of `filter`
          for (let m = 0; m < mappings.length; m++) {
            const mapping = mappings[m];
            if (seed >= mapping[1] && seed < mapping[1] + mapping[2]) {
              mappingFound = mapping;
              break;
            }
          }

          if (mappingFound) {
            batchSeedArray[i] = seed - mappingFound[1] + mappingFound[0];
          }
        }
      });

      // Calculate local min location for this batch
      let localMin = Infinity;
      for (let i = 0; i < batchSeedArray.length; i++) {
        if (batchSeedArray[i] < localMin) {
          localMin = batchSeedArray[i];
        }
      }
      minLocations.push(localMin);
    }
  });

  // Calculate global minimum
  const globalMinimum = Math.min(...minLocations);
  console.log(globalMinimum);
  console.log(`Execution time: ${(Date.now() - start) / 1000} seconds`);
};

p2();
