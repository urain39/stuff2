interface IMap<V> {
    [key: string]: V | V[];
    [index: number]: V | V[];
}

type JSONPrimitiveType = number | string | boolean | null;

interface JSONObjectType extends IMap<JSONPrimitiveType | JSONObjectType> {};

interface JSONArrayType extends Array<JSONPrimitiveType | JSONObjectType | JSONArrayType> {};

export type JSONType = JSONPrimitiveType | JSONObjectType | JSONArrayType;
