export interface IMap<V> {
    [key: string]: V | V[];
    [index: number]: V | V[];
}

export interface JSONType extends IMap<JSONType | string | number | null> {};
